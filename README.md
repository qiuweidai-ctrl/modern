# Laboratory work 4 — a local Docker image with a web server and a database

**Course:** Modern Programming Platforms
**Student:** DAI QIUWEI (Дай Цювэй), Group P1234

## Task

1. Create a new Git repository.
2. Build a local Docker image consisting of the base operating system, a web
   server (or application server) and a relational database management system.
   Source images are taken from Docker Hub or other verified sources.
3. Include the image in the Git project.

This repository contains the implementation of the work together with the
exported image, so that the image itself is part of the Git project.

## What is inside the image

| Layer | Component | Version | Source |
|-------|-----------|---------|--------|
| Base operating system | Alpine Linux | 3.20 | official `alpine:3.20` image from Docker Hub (`docker.io/library/alpine`, digest `sha256:d9e853e87e55526f6b2917df91a2115c36dd7c696a35be12163d44e6e2a4b6bc`) |
| Web server | nginx | 1.26.3-r0 | Alpine `main` repository, package `nginx` |
| RDBMS | MariaDB Server | 10.11.18-r0 | Alpine `main` repository, packages `mariadb` and `mariadb-client` |
| Time zone data | tzdata | 2026b-r0 | Alpine `main` repository |

Image tag: `lab4-alpine-nginx-mariadb:1.0`.

## Repository layout

```
.
├── Dockerfile                                  definition of the image
├── .dockerignore                               files excluded from the build context
├── .gitignore
├── docker
│   ├── entrypoint.sh                           starts MariaDB, creates the demo database, starts nginx
│   ├── mariadb.cnf                             enables the TCP listener on port 3306
│   ├── nginx.conf                              nginx virtual host
│   └── www
│       └── index.html                          demo page served by nginx
├── image
│   └── lab4-alpine-nginx-mariadb-1.0.tar.gz    exported image (75.9 MB)
└── README.md
```

## Build the image

```console
docker build -t lab4-alpine-nginx-mariadb:1.0 .
```

## Run the container

```console
docker run -d --name lab4 -p 8080:80 -p 3307:3306 lab4-alpine-nginx-mariadb:1.0
```

* web page — <http://localhost:8080/>
* database status page — <http://localhost:8080/db-status.html>
* MariaDB — `localhost:3307` (user `lab4user`, password `lab4pass`)

## Verify the container

```console
curl http://localhost:8080/
docker exec lab4 mariadb -h 127.0.0.1 -u lab4user -plab4pass -e "SELECT VERSION(); SHOW DATABASES;"
```

## How the image is stored in Git

The image is exported to an archive and committed, so the repository contains
the image itself and not only the Dockerfile:

```console
docker save -o image/lab4-alpine-nginx-mariadb-1.0.tar lab4-alpine-nginx-mariadb:1.0
gzip -9 image/lab4-alpine-nginx-mariadb-1.0.tar
git add image/lab4-alpine-nginx-mariadb-1.0.tar.gz
git commit -m "Add exported Docker image"
```

To restore the image on another machine:

```console
docker load -i image/lab4-alpine-nginx-mariadb-1.0.tar.gz
docker run -d --name lab4 -p 8080:80 -p 3307:3306 lab4-alpine-nginx-mariadb:1.0
```

## Notes

* The credentials (`lab4db`, `lab4user`, `lab4pass`) exist only to demonstrate
  that the database is reachable from the web server inside the same image.
  They are defaults of the entrypoint script and can be overridden with
  `-e MARIADB_PASSWORD=...`; they must not be used in production.
* MariaDB listens on port 3306 and nginx on port 80 inside the container.
  Only the port of the web server has to be published; publishing the database
  port (3307 in the command above) is optional and should be avoided in
  production.
* The database files are stored in an anonymous volume mounted at
  `/var/lib/mysql`, so the data survives a restart of the container.
