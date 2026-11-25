#!/usr/bin/env bash
# ReadyStack MariaDB entrypoint. Runs as the non-root mysql user.
#
# First start (no /var/lib/mysql/mysql directory): refuses to initialise unless MARIADB_ROOT_PASSWORD
# (or MARIADB_ROOT_PASSWORD_FILE) is at least 8 characters and not a well-known example password;
# MARIADB_ALLOW_EMPTY_ROOT_PASSWORD and MARIADB_RANDOM_ROOT_PASSWORD are refused. The MYSQL_* names of
# the official images are accepted as aliases. It runs mariadb-install-db (--force: no DNS lookup), starts a bootstrap server with
# no TCP listener (--skip-networking), removes the password-less root@127.0.0.1/::1/<hostname> accounts,
# sets the root password over the Unix socket and creates mysql@localhost (unix_socket, no privileges)
# for the health check, before the real server opens a port.
# A marker file covers the bootstrap: if it is interrupted, every later start refuses to run, because
# the data directory may then hold root accounts with no password. The HEALTHCHECK also reports
# unhealthy while the marker exists, so the bootstrap server is never mistaken for the real one.
# Arguments after the image name go to mariadbd; a first argument that is not an option is run instead.
set -Eeuo pipefail
BASEDIR=/usr/local/mariadb
export PATH="$BASEDIR/bin:$PATH"
DATADIR=/var/lib/mysql
MARKER="$DATADIR/.readystack-init-incomplete"

die() { echo "readystack: $*" >&2; exit 1; }

case "${1:-}" in mariadbd|mysqld) shift ;; esac
if [ -n "${1:-}" ] && [ "${1#-}" = "$1" ]; then exec "$@"; fi

for n in ROOT_PASSWORD ROOT_PASSWORD_FILE ROOT_HOST DATABASE USER PASSWORD PASSWORD_FILE; do
  m="MARIADB_$n"; o="MYSQL_$n"
  if [ -z "${!m:-}" ] && [ -n "${!o:-}" ]; then export "$m=${!o}"; fi
done

file_env() {
  local var="$1" fvar="${1}_FILE"
  if [ -n "${!var:-}" ] && [ -n "${!fvar:-}" ]; then die "set $var or $fvar, not both"; fi
  if [ -n "${!fvar:-}" ]; then
    [ -r "${!fvar}" ] || die "$fvar names ${!fvar}, which is not a readable file"
    export "$var=$(< "${!fvar}")"
  fi
}

# Succeeds (password refused) when it is shorter than 8 characters or a well-known example value.
weak_password() {
  local lc
  [ "${#1}" -ge 8 ] || return 0
  lc="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')"
  case "$lc" in
    password|passw0rd|password1|12345678|123456789|1234567890|changeme|change-me|changeit|my-secret-pw|mysecretpassword|rootpassword|your_password|your_root_password|your_secret) return 0 ;;
  esac
  return 1
}

sql_string() { local s="${1//\\/\\\\}"; s="${s//\'/\\\'}"; printf "'%s'" "$s"; }
sql_ident() { printf '`%s`' "${1//\`/\`\`}"; }

if [ -e "$MARKER" ]; then
  die "the first-start initialisation of $DATADIR did not finish ($MARKER exists), so the data directory may hold root accounts with no password. Remove this data directory (the volume) and start again."
fi

if [ ! -d "$DATADIR/mysql" ]; then
  file_env MARIADB_ROOT_PASSWORD
  file_env MARIADB_PASSWORD
  for v in MARIADB_ALLOW_EMPTY_ROOT_PASSWORD MYSQL_ALLOW_EMPTY_PASSWORD MARIADB_RANDOM_ROOT_PASSWORD MYSQL_RANDOM_ROOT_PASSWORD; do
    [ -z "${!v:-}" ] || die "$v is not supported by this image; set MARIADB_ROOT_PASSWORD."
  done
  [ -n "${MARIADB_ROOT_PASSWORD:-}" ] || die "MARIADB_ROOT_PASSWORD is not set. This image does not create a root account without a password: set MARIADB_ROOT_PASSWORD (or MARIADB_ROOT_PASSWORD_FILE) to a password of at least 8 characters."
  if weak_password "$MARIADB_ROOT_PASSWORD"; then
    die "MARIADB_ROOT_PASSWORD is shorter than 8 characters or is a well-known example password; choose another one."
  fi
  if [ -n "${MARIADB_USER:-}" ]; then
    [ "$MARIADB_USER" != root ] || die "MARIADB_USER=root is not allowed: the root account is created from MARIADB_ROOT_PASSWORD."
    [ -n "${MARIADB_PASSWORD:-}" ] || die "MARIADB_USER is set but MARIADB_PASSWORD is not."
    if weak_password "$MARIADB_PASSWORD"; then
      die "MARIADB_PASSWORD is shorter than 8 characters or is a well-known example password; choose another one."
    fi
  elif [ -n "${MARIADB_PASSWORD:-}" ]; then
    die "MARIADB_PASSWORD is set but MARIADB_USER is not."
  fi
  [ -w "$DATADIR" ] || die "$DATADIR is not writable by uid $(id -u) ($(id -un)); a host directory mounted there must belong to that uid."
  root_host="${MARIADB_ROOT_HOST:-%}"

  : > "$MARKER"
  echo "readystack: initialising a new data directory in $DATADIR"
  "$BASEDIR/scripts/mariadb-install-db" --basedir="$BASEDIR" --datadir="$DATADIR" \
    --auth-root-authentication-method=normal --skip-test-db --skip-name-resolve --force "$@"
  mariadbd --basedir="$BASEDIR" --datadir="$DATADIR" --skip-networking "$@" &
  pid=$!
  ready=
  for _ in $(seq 1 120); do
    if mariadb-admin -uroot --silent ping >/dev/null 2>&1; then ready=1; break; fi
    kill -0 "$pid" 2>/dev/null || die "the bootstrap server exited during initialisation (see the log above)"
    sleep 1
  done
  [ -n "$ready" ] || die "the bootstrap server did not answer within 120 seconds"

  {
    echo "SET @@SESSION.SQL_LOG_BIN=0;"
    echo "SET @@SESSION.SQL_MODE=REPLACE(@@SESSION.SQL_MODE,'NO_BACKSLASH_ESCAPES','');"
    echo "SET @extra_root=(SELECT IFNULL(GROUP_CONCAT(CONCAT(QUOTE(User),'@',QUOTE(Host)) SEPARATOR ', '),'') FROM mysql.global_priv WHERE User='root' AND Host<>'localhost');"
    echo "SET @drop_root=IF(@extra_root='','DO 0',CONCAT('DROP USER ',@extra_root));"
    echo "EXECUTE IMMEDIATE @drop_root;"
    echo "ALTER USER 'root'@'localhost' IDENTIFIED BY $(sql_string "$MARIADB_ROOT_PASSWORD");"
    if [ "$root_host" != localhost ]; then
      echo "CREATE USER 'root'@$(sql_string "$root_host") IDENTIFIED BY $(sql_string "$MARIADB_ROOT_PASSWORD");"
      echo "GRANT ALL ON *.* TO 'root'@$(sql_string "$root_host") WITH GRANT OPTION;"
      echo "GRANT PROXY ON ''@'%' TO 'root'@$(sql_string "$root_host") WITH GRANT OPTION;"
    fi
    echo "CREATE USER 'mysql'@'localhost' IDENTIFIED VIA unix_socket;"
    if [ -n "${MARIADB_DATABASE:-}" ]; then
      echo "CREATE DATABASE IF NOT EXISTS $(sql_ident "$MARIADB_DATABASE");"
    fi
    if [ -n "${MARIADB_USER:-}" ]; then
      echo "CREATE USER $(sql_string "$MARIADB_USER")@'%' IDENTIFIED BY $(sql_string "$MARIADB_PASSWORD");"
      if [ -n "${MARIADB_DATABASE:-}" ]; then
        echo "GRANT ALL ON $(sql_ident "$MARIADB_DATABASE").* TO $(sql_string "$MARIADB_USER")@'%';"
      fi
    fi
  } | mariadb -uroot

  export MYSQL_PWD="$MARIADB_ROOT_PASSWORD"
  for f in /docker-entrypoint-initdb.d/*; do
    [ -e "$f" ] || continue
    case "$f" in
      *.sh)  echo "readystack: running $f"; . "$f" ;;
      *.sql) echo "readystack: running $f"; mariadb -uroot ${MARIADB_DATABASE:+"--database=$MARIADB_DATABASE"} < "$f" ;;
      *)     echo "readystack: ignoring $f" ;;
    esac
  done
  mariadb-admin -uroot shutdown
  wait "$pid"
  unset MYSQL_PWD
  rm -f "$MARKER"
  echo "readystack: initialisation complete"
fi

exec mariadbd --basedir="$BASEDIR" --datadir="$DATADIR" "$@"
