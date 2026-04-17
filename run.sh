#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

ENV_NAME="${1:?Usage: ./run.sh <env> <dump_file>}"
DUMP_FILE="${2:?Usage: ./run.sh <env> <dump_file>}"

if [[ ! -f "src/${DUMP_FILE}" ]]; then
    echo "Error: src/${DUMP_FILE} not found"
    exit 1
fi

docker run --rm \
    -e MARIADB_ALLOW_EMPTY_ROOT_PASSWORD=yes \
    -e HOST_UID="$(id -u)" \
    -e HOST_GID="$(id -g)" \
    -v "$(pwd)/src:/src" \
    strip-db:latest \
    bash -c "
        docker-entrypoint.sh mariadbd --innodb-log-file-size=1G &
        until mariadb-admin ping -h 127.0.0.1 --protocol=tcp --silent 2>/dev/null; do sleep 1; done
        bash /src/strip.sh ${ENV_NAME} ${DUMP_FILE}
    "
