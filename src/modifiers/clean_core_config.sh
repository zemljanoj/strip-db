#!/usr/bin/env bash
set -euo pipefail

DB_NAME="${1:?DB name required}"
ENV_NAME="${2:?Env name required}"

CONFIG="/src/config.yml"

COUNT=$(yq ".mode.${ENV_NAME}.clean_core_config | length" "$CONFIG")

if [[ "$COUNT" == "0" || "$COUNT" == "null" ]]; then
    echo "Modifier: No core_config_data entries to clean"
    exit 0
fi

echo "Modifier: Cleaning ${COUNT} core_config_data entries..."

for i in $(seq 0 $((COUNT - 1))); do
    PATH_PATTERN=$(yq ".mode.${ENV_NAME}.clean_core_config[$i].path" "$CONFIG")
    SCOPE=$(yq ".mode.${ENV_NAME}.clean_core_config[$i].scope // \"default\"" "$CONFIG")
    SCOPE_ID=$(yq ".mode.${ENV_NAME}.clean_core_config[$i].scope_id // \"0\"" "$CONFIG")

    echo "  Deleting: path='${PATH_PATTERN}' scope='${SCOPE}' scope_id='${SCOPE_ID}'"
    mysql "$DB_NAME" -e "DELETE FROM core_config_data WHERE path LIKE '${PATH_PATTERN}' AND scope = '${SCOPE}' AND scope_id = ${SCOPE_ID};"
done
