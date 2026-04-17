#!/usr/bin/env bash
set -euo pipefail

ENV_NAME="${1:?Usage: strip.sh <env> <dump_file>}"
DUMP_FILE="${2:?Usage: strip.sh <env> <dump_file>}"

CONFIG="/src/config.yml"

DB_NAME=$(yq '.db_name' "$CONFIG")
OUTPUT_FILE=$(yq ".mode.${ENV_NAME}.output_file" "$CONFIG")

if [[ "$OUTPUT_FILE" == "null" ]]; then
    echo "Error: mode '${ENV_NAME}' not found in config"
    exit 1
fi

OUTPUT_SQL="${OUTPUT_FILE%.gz}"

echo "=== Strip DB: env=${ENV_NAME}, dump=${DUMP_FILE} ==="

# Create database
echo "Creating database ${DB_NAME}..."
mariadb -e "CREATE DATABASE \`${DB_NAME}\`;"

# Import dump
echo "Importing dump..."
if [[ "$DUMP_FILE" == *.gz ]]; then
    gunzip -c "/src/${DUMP_FILE}" | mariadb "$DB_NAME"
else
    mariadb "$DB_NAME" < "/src/${DUMP_FILE}"
fi

# Run modifiers
MODIFIER_COUNT=$(yq ".mode.${ENV_NAME}.modifiers | length" "$CONFIG")
for i in $(seq 0 $((MODIFIER_COUNT - 1))); do
    MODIFIER=$(yq ".mode.${ENV_NAME}.modifiers[$i]" "$CONFIG")
    echo "Running modifier: ${MODIFIER}"
    bash "/src/modifiers/${MODIFIER}" "$DB_NAME" "$ENV_NAME"
done

# Export database
echo "Exporting database..."
mariadb-dump \
  --single-transaction \
  --compatible=mysql \
    "$DB_NAME" > "/src/${OUTPUT_SQL}"

# Compress
echo "Compressing..."
gzip "/src/${OUTPUT_SQL}"

# Fix ownership to match host user
if [[ -n "${HOST_UID:-}" && -n "${HOST_GID:-}" ]]; then
    chown "${HOST_UID}:${HOST_GID}" "/src/${OUTPUT_FILE}"
fi

# Cleanup
echo "Dropping database..."
mariadb -e "DROP DATABASE \`${DB_NAME}\`;"

echo "=== Done: /src/${OUTPUT_FILE} ==="
