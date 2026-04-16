#!/usr/bin/env bash
set -euo pipefail

DB_NAME="${1:?DB name required}"
ENV_NAME="${2:?Env name required}"

CONFIG="/src/config.yml"

# Resolve clean_table_groups
GROUP_COUNT=$(yq ".mode.${ENV_NAME}.clean_table_groups | length" "$CONFIG")
for i in $(seq 0 $((GROUP_COUNT - 1))); do
    GROUP=$(yq ".mode.${ENV_NAME}.clean_table_groups[$i]" "$CONFIG")
    TABLE_COUNT=$(yq ".clean_table_groups.${GROUP} | length" "$CONFIG")
    for j in $(seq 0 $((TABLE_COUNT - 1))); do
        TABLE=$(yq ".clean_table_groups.${GROUP}[$j]" "$CONFIG")
        echo "  Cleaning table: ${TABLE}"
        mysql "$DB_NAME" -e "DELETE FROM \`${TABLE}\`;"
    done
done

# Clean individual tables
TABLE_COUNT=$(yq ".mode.${ENV_NAME}.clean_tables | length" "$CONFIG")
for i in $(seq 0 $((TABLE_COUNT - 1))); do
    TABLE=$(yq ".mode.${ENV_NAME}.clean_tables[$i]" "$CONFIG")
    echo "  Cleaning table: ${TABLE}"
    mysql "$DB_NAME" -e "DELETE FROM \`${TABLE}\`;"
done
