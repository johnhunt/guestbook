# Guestbook docker-compose devops test project

## ⚠️ Warning! 

This project should definitely NOT be run in a production environment, it is purely to showcase my (John Hunt's) technical abilities in regards to a job application. I have not spent *any* time securing this code.

## About

This is a very simple three-tiered guestbook app. Basically you have a single page where you can sign the guestbook and see previous messages.

There are two docker-compose files - `docker-compose` is for local **deployment**, `docker-compose-develop` is for local **development**. The difference is that the develop compose file mounts the src-ui and src-api directories in this project and hot-loads from them making development a breeze (no more nvm, npm etc)!

Cloud deployment is outside the scope of this project, however I have provided some terraform code to show the resources that could be created if you were to run this in the cloud.

**In order to work with this project, you will need docker-compose. Find out more here: https://docs.docker.com/compose/**

## Local deployment

You can deploy to your local machine, or simply clone the project to any server or virtual machine you'd like to host from and run:

    DB_PASSWORD=topsecret2025foobbq docker-compose up -d --build

Replace the database password with a secure one of your choosing. Running this command creates 3 container images that are then executed:

  1. A web container running NginX which serves the compiled React app from the `src-ui` directory.
  2. A FastAPI Python app built from the source code within `src-api`
  3. A postgres database server to provide persistent storage.

You can then view the app at http://localhost:8080

## Local development

Local development is possible by using the `docker-compose-develop` file.

    docker-compose -f docker-compose-develop.yml up -d

You can then view the app at http://localhost:9090 and edit any of the files in `src-ui` and `src-api` with the changes loaded automatically when you save your files.

**Note that for ease of development, the database credentials are hardcoded in the docker-compose-develop.yml file.**

