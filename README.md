# Guestbook app

Please don't use this code in production - its original purpose was to showcase my (John Hunt) devops abilities for a job application. If you use it in production then all kinds of bad things might happen so please don't.

## Prerequisits

- npm
- docker-compose

## Local deployment with docker-compose

Use this to spin up the web server, API and database quickly to test it builds properly and to try out the application locally with minimal fuss. Use a unique password in place of `topsecret2025foobbq`, this will be your local database password.

    DB_PASSWORD=topsecret2025foobbq docker-compose up -d --build

Be sure to `docker compose down` when before development as it uses the same ports.

### Run the UI in development mode

You might want to work on the UI, in which case just run

    cd src-ui/
    npm run dev

This spins up a local dev server which hot-reloads the app making it easier to develop.

### Check your UI code for errors/formatting

    npm run lint

### Working on the API code

For local development you'll want to ensure the local database is running first, you can do this by running:

   DB_PASSWORD=topsecret2025foobbq docker-compos run -p 127.0.0.1:5432:5432 -d db #@todo - will localhost work here?

This also exposes the database to the local machine for developing with.

Ensure the virtual environment is activated
    
    cd src-api
    source .venv/bin/activate

Install required packages

    pip install -r requirements.txt

Start the dev API server (runs on port 8000)

    DATABASE_URL=postgresql://postgres:topsecret2025foobbq@localhost:5432/mydatabase fastapi dev main.py

### Database migrations

If you create a new model in models.py then you'll need to create a new migration file to reflect this. These migrations are run when the API starts up (although you can apply them manually if you like):

   DATABASE_URL=postgresql://postgres:topsecret2025foobbq@localhost:5432/mydatabase alembic revision --autogenerate -m "Create guestbook_entries table"

# Deploying infrastructure to the cloud

Infrastructure for this project is defined in the `infrastructure/` directory with Azure as the cloud provider in mind. IaC is written in terraform. To deploy you'll need these tools:

 - terraform
 - az cli

Simply login to Azure (`az login`) then run terraform plan to check, followed by apply:
    cd infrastructure
    terraform plan
    terraform apply

This will deploy infrastructure for both dev and production but NOT any code - that is out of scope for this project.