# Guestbook app

Please don't use this code in production - its original purpose was to showcase my (John Hunt) devops abilities for a job application. If you use it in production then all kinds of bad things might happen so please don't.

## Prerequisits

- npm
- docker-compose

## Local deployment with docker-compose

Use this to spin up the web server, API and database quickly to test it builds properly and to try out the application locally with minimal fuss. Use a unique password in place of `topsecret2025foobbq`, this will be your local database password.

    DB_PASSWORD=topsecret2025foobbq docker-compose up -d

Be sure to `docker compose down` when before development as it uses the same ports.

### Run the UI in development mode

You might want to work on the UI, in which case just run

    cd src-ui/
    npm run dev

This spins up a local dev server which hot-reloads the app making it easier to develop.

### Check your UI code for errors/formatting

    npm run lint

### Develop the API

For local development you'll want to ensure the local database is running first, you can do this by running:

   DB_PASSWORD=topsecret2025foobbq docker compose -f 'docker-compose.yml' up --build 'db'

Note, you'll need to prefix the docker compose command with 

Ensure the virtual environment is activated

    source .venv/bin/activate

Install required packages

    pip install -r requirements.txt

Start the dev API server (runs on port 8000)

    fastapi dev main.py

