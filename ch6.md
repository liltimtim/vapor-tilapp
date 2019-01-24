# Configuring Databases

Since Vapor depends on Swift Package Manager, you must install the packages that interact with the database.

### PostgreSQL

PostgreSQL is a popular choice, used throughout the book as well.

1. configure Docker

execute the following command to setup a postgres database

```shell
docker run --name postgres -e POSTGRES_DB=vapor -e POSTGRES_USER=vapor -e POSTGRES_PASSWORD=password -p 5432:5432 -d postgres
```
