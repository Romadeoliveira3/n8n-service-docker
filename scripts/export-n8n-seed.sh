#!/bin/bash
set -euo pipefail

echo "[seed] Gerando dump do banco n8n..."

# Carrega variáveis do arquivo .env, se existir (POSTGRES_DB, POSTGRES_USER, POSTGRES_PASSWORD, etc.)
if [ -f .env ]; then
  set -a
  # shellcheck disable=SC1091
  . .env
  set +a
fi

: "${POSTGRES_USER:=n8n}"
: "${POSTGRES_PASSWORD:=changeme}"
: "${POSTGRES_DB:=n8n}"
: "${POSTGRES_CONTAINER:=n8n-postgres}"
: "${SEED_FILE:=db/seed-n8n.sql}"

if ! docker ps --format '{{.Names}}' | grep -q "^${POSTGRES_CONTAINER}\$"; then
  echo "[seed] Container ${POSTGRES_CONTAINER} não está rodando."
  exit 1
fi

mkdir -p "$(dirname "${SEED_FILE}")"

docker exec -e "PGPASSWORD=${POSTGRES_PASSWORD}" "${POSTGRES_CONTAINER}" \
  pg_dump -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" > "${SEED_FILE}"

echo "[seed] Seed gerado em ${SEED_FILE}"
