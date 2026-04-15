# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

strip-db is a Docker-based tool for stripping sensitive data from Magento 2 MySQL database dumps. It imports a SQL dump into a temporary MySQL 8 container, runs modifier scripts (e.g., clearing admin passwords), then re-exports the dump excluding configured tables (customers, orders, etc.). The result is a sanitized `.sql.gz` file safe for dev/QA environments.

## Usage

```bash
# Build the Docker image (mysql:8 + yq)
./build.sh

# Strip a dump: ./run.sh <env> <dump_file>
# <env> matches a key under `mode:` in src/config.yml
# <dump_file> is relative to src/ (.sql or .sql.gz)
./run.sh dev weibulls.sql.gz
```

Output is written to `src/<output_file>` as defined in config.

## Architecture

- **`run.sh`** — Entry point. Starts a disposable MySQL container, mounts `src/`, calls `src/strip.sh`.
- **`src/strip.sh`** — Core logic: creates DB, imports dump, runs modifiers, exports structure (all tables) + data (minus ignored tables), compresses, drops DB.
- **`src/config.yml`** — Per-project configuration (copy from `config.yml.example`). Defines:
  - `db_name` — temporary database name inside the container
  - `mode.<env>` — environment profiles (dev, qa) with `output_file`, `modifiers`, `ignore_table_groups`, `ignore_tables`
  - `ignore_table_groups` — reusable named lists of tables to exclude (customer, order)
- **`src/modifiers/`** — Bash scripts that run SQL modifications before export. Each receives the DB name as `$1`. Example: `remove_admin_password.sh` blanks `admin_user.password`.

## Key Details

- Config is parsed with `yq` (v4), installed in the Docker image.
- The dump export uses two `mysqldump` passes: first structure-only (all tables), then data-only (excluding ignored tables).
- SQL dumps placed in `src/` are gitignored; `config.yml` is also gitignored (use `config.yml.example` as template).
