# ---------------------------------------------------------------------------
# Laboratory work 4  -  a local Docker image with a web server and a database
#
# Base image : alpine:3.20   (official image published on Docker Hub)
# Software   : nginx         (web server)
#              MariaDB       (relational database management system)
#
# Build : docker build -t lab4-alpine-nginx-mariadb:1.0 .
# Run   : docker run -d --name lab4 -p 8080:80 lab4-alpine-nginx-mariadb:1.0
# ---------------------------------------------------------------------------
FROM alpine:3.20

LABEL org.opencontainers.image.title="lab4-alpine-nginx-mariadb" \
      org.opencontainers.image.description="Alpine Linux + nginx + MariaDB in one local image" \
      org.opencontainers.image.authors="DAI QIUWEI" \
      org.opencontainers.image.version="1.0"

# Name of the demo database and of its user.  The password is deliberately not
# stored here: the entrypoint script uses a demo default that can be overridden
# at run time, e.g.  docker run -e MARIADB_PASSWORD=... .
ENV MARIADB_DATABASE=lab4db \
    MARIADB_USER=lab4user

# Install the web server and the database server from the Alpine repositories.
RUN apk add --no-cache nginx mariadb mariadb-client tzdata \
    && mkdir -p /run/mysqld /var/log/nginx \
    && chown -R mysql:mysql /run/mysqld /var/lib/mysql

# Configuration of the virtual host, the demo page and the start-up script.
COPY docker/nginx.conf          /etc/nginx/http.d/default.conf
COPY docker/mariadb.cnf         /etc/my.cnf.d/zz-lab4.cnf
COPY docker/www/index.html      /var/www/localhost/htdocs/index.html
COPY docker/entrypoint.sh       /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# 80 - HTTP (nginx), 3306 - MySQL/MariaDB protocol.
EXPOSE 80 3306

# The database files are kept outside the container layer.
VOLUME ["/var/lib/mysql"]

# A simple availability check: nginx must answer on port 80.
HEALTHCHECK --interval=30s --timeout=3s --start-period=20s --retries=3 \
    CMD wget -q -O /dev/null http://127.0.0.1/ || exit 1

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
