#!/bin/bash
set -euo pipefail

log() {
  echo "[$(date --iso-8601=seconds)] $*"
}

wait_for_database() {
  local db_type host port attempts delay
  db_type=${DB_TYPE:-postgresdb}
  host=${DB_POSTGRESDB_HOST:-}
  port=${DB_POSTGRESDB_PORT:-5432}
  attempts=${DB_STARTUP_ATTEMPTS:-30}
  delay=${DB_STARTUP_DELAY:-2}

  if [[ "$db_type" != "postgresdb" || -z "$host" ]]; then
    return
  }

  log "Waiting for Postgres at ${host}:${port} (max ${attempts} attempts)."
  for ((i=1; i<=attempts; i++)); do
    if (echo >/dev/tcp/"$host"/"$port") >/dev/null 2>&1; then
      log "Postgres is reachable."
      return
    fi
    log "Attempt ${i}/${attempts} failed, retrying in ${delay}s..."
    sleep "$delay"
  done
  log "Database is still unreachable but continuing so container can surface errors from n8n."
}

import_workflows() {
  local workflow_dir overwrite_flag lowercase_flag workflow_files
  workflow_dir=${WORKFLOW_DIR:-/workflows}
  overwrite_flag=${N8N_IMPORT_OVERWRITE:-true}
  lowercase_flag=$(echo "$overwrite_flag" | tr '[:upper:]' '[:lower:]')

  if [[ ! -d "$workflow_dir" ]]; then
    log "Workflow directory ${workflow_dir} does not exist, skipping import."
    return
  fi

  shopt -s nullglob
  workflow_files=(${workflow_dir}/*.json)
  shopt -u nullglob

  if [[ ${#workflow_files[@]} -eq 0 ]]; then
    log "No workflow exports (*.json) found in ${workflow_dir}, skipping import."
    return
  fi

  log "Importing ${#workflow_files[@]} workflow file(s) from ${workflow_dir}."
  for workflow in "${workflow_files[@]}"; do
    log "Importing workflow ${workflow}."
    if [[ "$lowercase_flag" == "true" ]]; then
      n8n import:workflow --input "$workflow" --overwrite
    else
      n8n import:workflow --input "$workflow"
    fi
  done
}

trust_custom_certificates() {
  if [[ -d /opt/custom-certificates ]]; then
    log "Trusting custom certificates from /opt/custom-certificates."
    export NODE_OPTIONS="--use-openssl-ca ${NODE_OPTIONS:-}"
    export SSL_CERT_DIR=/opt/custom-certificates
    c_rehash /opt/custom-certificates
  fi
}

trust_custom_certificates
wait_for_database
import_workflows

if [[ "$#" -gt 0 ]]; then
  exec n8n "$@"
else
  exec n8n
fi
