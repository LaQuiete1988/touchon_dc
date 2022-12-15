#!/bin/sh

if [ ! -d "/run/mysqld" ]; then
  mkdir -p /run/mysqld
  chown -R mysql:mysql /run/mysqld
fi

if [ -d /var/lib/mysql/mysql ]; then
  echo "MySQL data directory already exists"
else
  echo "MySQL data directory doesn't exist. Installing DBs"
  chown -R mysql:mysql /var/lib/mysql
  mysql_install_db --user=mysql > /dev/null

  # MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-""}
  # MYSQL_DATABASE=${MYSQL_DATABASE:-""}
  # MYSQL_USER=${MYSQL_USER:-""}
  # MYSQL_PASSWORD=${MYSQL_PASSWORD:-""}

  tfile=`mktemp`
  if [ ! -f "$tfile" ]; then
      return 1
  fi

  cat << EOF > $tfile
FLUSH PRIVILEGES;
CREATE DATABASE ${MYSQL_DATABASE:-""} CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
DROP DATABASE test;
DROP USER ''@'localhost';
GRANT ALL ON ${MYSQL_DATABASE:-""}.* to '${MYSQL_USER:-""}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD:-""}';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD:-""}';
FLUSH PRIVILEGES;
EOF

  /usr/bin/mysqld --user=mysql --bootstrap --verbose=0 < $tfile
  rm -f $tfile
fi

# exec /usr/bin/mysqld --user=mysql --console
exec /bin/sh -c "crond && mysqld --user=mysql --console"