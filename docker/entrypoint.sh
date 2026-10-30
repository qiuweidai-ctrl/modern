#!/bin/sh
# ---------------------------------------------------------------------------
# Start-up script of the lab4 image.
#
# A container runs exactly one foreground process, but this image contains
# two services (MariaDB and nginx).  The script therefore starts MariaDB in
# the background, waits until it accepts connections, creates the demo
# database, and finally replaces itself with nginx, which becomes PID 1.
# ---------------------------------------------------------------------------
set -e

DATADIR="/var/lib/mysql"
SOCKET="/run/mysqld/mysqld.sock"

# Defaults for the demo database.  They can all be overridden with -e at run
# time; the password in particular must never be used in production.
MARIADB_DATABASE="${MARIADB_DATABASE:-lab4db}"
MARIADB_USER="${MARIADB_USER:-lab4user}"
MARIADB_PASSWORD="${MARIADB_PASSWORD:-lab4pass}"

# Initialise the data directory only once, so that a mounted volume keeps the
# data between restarts of the container.
if [ ! -d "$DATADIR/mysql" ]; then
    echo "[entrypoint] initialising the MariaDB data directory"
    mariadb-install-db --user=mysql --datadir="$DATADIR" --skip-test-db >/dev/null
fi

echo "[entrypoint] starting MariaDB"
mariadbd --user=mysql --datadir="$DATADIR" --socket="$SOCKET" &
MARIADB_PID=$!

# Wait until the server accepts connections (maximum 60 seconds).
i=0
while [ "$i" -lt 60 ]; do
    if mariadb-admin --socket="$SOCKET" ping --silent >/dev/null 2>&1; then
        break
    fi
    i=$((i + 1))
    sleep 1
done

echo "[entrypoint] creating the demo database and table"
mariadb --socket="$SOCKET" -u root <<SQL
CREATE DATABASE IF NOT EXISTS ${MARIADB_DATABASE};
CREATE USER IF NOT EXISTS '${MARIADB_USER}'@'%' IDENTIFIED BY '${MARIADB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MARIADB_DATABASE}.* TO '${MARIADB_USER}'@'%';
FLUSH PRIVILEGES;
USE ${MARIADB_DATABASE};
CREATE TABLE IF NOT EXISTS visits (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    visited_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    note       VARCHAR(128) NOT NULL
);
INSERT INTO visits (note) VALUES ('container started');
SQL

# Generate a status page so that nginx can show that MariaDB is reachable
# from inside the same image.
DB_VERSION=$(mariadb --socket="$SOCKET" -u root -N -B -e "SELECT VERSION();")
DB_ROWS=$(mariadb --socket="$SOCKET" -u root -N -B -e \
          "SELECT COUNT(*) FROM ${MARIADB_DATABASE}.visits;")

cat > /var/www/localhost/htdocs/db-status.html <<HTML
<!DOCTYPE html>
<html lang="en">
<head><meta charset="utf-8"><title>Database status</title></head>
<body>
<h1>MariaDB status</h1>
<p>Server version: <strong>${DB_VERSION}</strong></p>
<p>Database: <strong>${MARIADB_DATABASE}</strong></p>
<p>Rows in <code>visits</code>: <strong>${DB_ROWS}</strong></p>
</body>
</html>
HTML

echo "[entrypoint] starting nginx"
exec "$@"
