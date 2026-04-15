#!/usr/bin/env bash
set -euo pipefail

DB_NAME="${1:?DB name required}"

echo "Modifier: Removing admin passwords..."
mysql "$DB_NAME" -e "UPDATE admin_user SET password = '';"
