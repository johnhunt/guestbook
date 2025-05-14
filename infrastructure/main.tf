### Infrastructure to set up guestbook from scratch on Azure
### Note I ran this for real to make sure it was right!

### Resource groups

resource "azurerm_resource_group" "rg-dev" {
  location = "uksouth"
  name     = "rg-guestbook-dev"
}

# Normally we'd use a dev & prod subscription rather than RGs, but this isn't a real project
resource "azurerm_resource_group" "rg-prod" {
  location = "uksouth"
  name     = "rg-guestbook-prod"
}

### Virtual networks
resource "azurerm_virtual_network" "vnet-dev" {
  name                = "vnet-dev"
  address_space       = ["192.168.0.0/20"]
  location            = "uksouth"
  resource_group_name = azurerm_resource_group.rg-dev.name
}

resource "azurerm_virtual_network" "vnet-prod" {
  name                = "vnet-prod"
  address_space       = ["192.168.16.0/20"]
  location            = "uksouth"
  resource_group_name = azurerm_resource_group.rg-prod.name
}

### Subnets
resource "azurerm_subnet" "guestbook-subnet-dev" {
  name                 = "guestbook-subnet-dev"
  resource_group_name  = azurerm_resource_group.rg-dev.name
  virtual_network_name = azurerm_virtual_network.vnet-dev.name
  address_prefixes     = ["192.168.1.0/24"]
}

resource "azurerm_subnet" "guestbook-subnet-prod" {
  name                 = "guestbook-subnet-prod"
  resource_group_name  = azurerm_resource_group.rg-prod.name
  virtual_network_name = azurerm_virtual_network.vnet-prod.name
  address_prefixes     = ["192.168.16.0/24"]
}

### Container registries
resource "azurerm_container_registry" "acr-dev" {
  name                = "johnhuntdemoacrdev"
  resource_group_name = azurerm_resource_group.rg-dev.name
  location            = azurerm_resource_group.rg-dev.location
  sku                 = "Basic"
  admin_enabled       = true
}

resource "azurerm_container_registry" "acr-prod" {
  name                = "johnhuntdemoacrprod"
  resource_group_name = azurerm_resource_group.rg-prod.name
  location            = azurerm_resource_group.rg-prod.location
  sku                 = "Basic"
  admin_enabled       = true
}

### Databases
resource "azurerm_postgresql_flexible_server" "postgres-dev" {
  name                   = "guestbook-postgres-dev"
  resource_group_name    = azurerm_resource_group.rg-dev.name
  location               = azurerm_resource_group.rg-dev.location
  version                = "14"
  administrator_login    = "adminuser"
  administrator_password = var.postgres_admin_password
  storage_mb             = 32768
}

resource "azurerm_postgresql_flexible_server" "postgres-prod" {
  name                   = "guestbook-postgres-prod"
  resource_group_name    = azurerm_resource_group.rg-prod.name
  location               = azurerm_resource_group.rg-prod.location
  version                = "14"
  administrator_login    = "adminuser"
  administrator_password = var.postgres_admin_password
  storage_mb             = 32768
}

### Log analytics workspaces - for CAEs
resource "azurerm_log_analytics_workspace" "logs-dev" {
  name                = "logs-dev"
  location            = "uksouth"
  resource_group_name = azurerm_resource_group.rg-dev.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_log_analytics_workspace" "logs-prod" {
  name                = "logs-prod"
  location            = "uksouth"
  resource_group_name = azurerm_resource_group.rg-prod.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

### Container app environments
resource "azurerm_container_app_environment" "cae-env-dev" {
  name                       = "guestbook-env-dev"
  resource_group_name        = azurerm_resource_group.rg-dev.name
  location                   = azurerm_resource_group.rg-dev.location
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logs-dev.id
}

resource "azurerm_container_app_environment" "cae-env-prod" {
  name                       = "guestbook-env-prod"
  resource_group_name        = azurerm_resource_group.rg-prod.name
  location                   = azurerm_resource_group.rg-prod.location
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logs-prod.id
}

### Container apps (web server and API)
resource "azurerm_container_app" "web-app-dev" {
  name                         = "guestbook-web-app-dev"
  revision_mode                = "Single"
  resource_group_name          = azurerm_resource_group.rg-dev.name
  container_app_environment_id = azurerm_container_app_environment.cae-env-dev.id

  ingress {
    allow_insecure_connections = false
    target_port                = 80
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  registry {
    server               = "johnhuntdemoacrdev.azurecr.io"
    username             = "admin"
    password_secret_name = var.acr_password
  }

  ## Note this won't actually deploy as I didn't push anything to my ACR
  ## But hopefully you can see how it would work
  template {
    min_replicas = 2
    max_replicas = 2

    container {
      name   = "guestbook-web-app-dev"
      image  = "johnhuntdemoacrdev.azurecr.io/guestbook-web-app:latest"
      cpu    = "0.5"
      memory = "1.0Gi"
    }
  }
}

resource "azurerm_container_app" "web-app-prod" {
  name                         = "guestbook-web-app-prod"
  revision_mode                = "Single"
  resource_group_name          = azurerm_resource_group.rg-dev.name
  container_app_environment_id = azurerm_container_app_environment.cae-env-prod.id

  ingress {
    allow_insecure_connections = false
    target_port                = 80
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  registry {
    server               = "johnhuntdemoacrprod.azurecr.io"
    username             = "admin"
    password_secret_name = var.acr_password
  }

  ## Note this won't actually deploy as I didn't push anything to my ACR
  ## But hopefully you can see how it would work
  template {
    min_replicas = 2
    max_replicas = 2

    container {
      name   = "guestbook-web-app-prod"
      image  = "johnhuntdemoacrprod.azurecr.io/guestbook-web-app:latest"
      cpu    = "0.5"
      memory = "1.0Gi"
    }
  }
}

resource "azurerm_container_app" "api-dev" {
  name                         = "guestbook-api-dev"
  revision_mode                = "Single"
  resource_group_name          = azurerm_resource_group.rg-dev.name
  container_app_environment_id = azurerm_container_app_environment.cae-env-dev.id

  ingress {
    allow_insecure_connections = false
    target_port                = 80
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  registry {
    server               = "johnhuntdemoacrdev.azurecr.io"
    username             = "admin"
    password_secret_name = var.acr_password
  }

  ## Note this won't actually deploy as I didn't push anything to my ACR
  ## But hopefully you can see how it would work
  template {
    min_replicas = 2
    max_replicas = 2

    container {
      name   = "guestbook-api-dev"
      image  = "johnhuntdemoacrdev.azurecr.io/guestbook-api:latest"
      cpu    = "1"
      memory = "2.0Gi"
    }
  }
}


resource "azurerm_container_app" "api-prod" {
  name                         = "guestbook-api-prod"
  revision_mode                = "Single"
  resource_group_name          = azurerm_resource_group.rg-prod.name
  container_app_environment_id = azurerm_container_app_environment.cae-env-prod.id

  ingress {
    allow_insecure_connections = false
    target_port                = 80
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  registry {
    server               = "johnhuntdemoacrprod.azurecr.io"
    username             = "admin"
    password_secret_name = var.acr_password
  }

  ## Note this won't actually deploy as I didn't push anything to my ACR
  ## But hopefully you can see how it would work
  template {
    min_replicas = 2
    max_replicas = 2

    container {
      name   = "guestbook-api-dev"
      image  = "johnhuntdemoacrprod.azurecr.io/guestbook-api:latest"
      cpu    = "1"
      memory = "2.0Gi"
    }
  }
}