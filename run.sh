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
    -e MYSQL_ALLOW_EMPTY_PASSWORD=yes \
    -v "$(pwd)/src:/src" \
    strip-db:latest \
    bash -c "
        docker-entrypoint.sh mysqld &
        until mysqladmin ping -h 127.0.0.1 --protocol=tcp --silent 2>/dev/null; do sleep 1; done
        bash /src/strip.sh ${ENV_NAME} ${DUMP_FILE}
    "
