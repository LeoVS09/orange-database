# orang-database
Database for Orange, based on PostgreSQL and GraphQL 

## Development

Development requirements:
* Docker - latest
* Make - crosplatform make tool

### Setup local enviroment

```bash
# Command will generate configuration enviroment `.env` file which will be used by docker and serveless
make setup

# Will create in linux container console for you 
make console
```

### In docker isolated linux development
This project workig only on linux

For allow windows development you will develop all code inside docker container

This prevent problems:
* Not need support multiple OS
* Allow easy bootstrap project for new team members
* Allow not install all dev tools on local machine

For start development just write

```bash
# docker will create linux enviroment for you and map volume to current project folder
make console
```