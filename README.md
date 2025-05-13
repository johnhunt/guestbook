# Guestbook app

Please don't use this code in production - its original purpose was to showcase my (John Hunt) devops abilities for a job application. If you use it in production then all kinds of bad things might happen so please don't.

## Prerequisits

- npm
- docker-compose

## Build UI for use with docker-compose

Running the following commands will install dependancies for the UI and build it. The build directory is `ui-compiled` in the root of this project. This is mounted by docker-compose for NginX.

    cd src-ui/
    npm install
    npm run build

### Run the UI in development mode

You might want to work on the UI, in which case just run

    cd src-ui/
    npm run dev

This spins up a local dev server which hot-reloads the app making it easier to develop.

### Check your UI code for errors/formatting

    npm run lint