#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
BRANCH="${SUB2API_BRANCH:-ceen}"
COMPOSE_FILE="${SCRIPT_DIR}/docker-compose.local.yml"
ENV_FILE="${SCRIPT_DIR}/.env"

cd "${REPO_ROOT}"

if [ ! -f "${ENV_FILE}" ]; then
  echo "Missing ${ENV_FILE}. Create it from deploy/.env.example before starting Sub2API." >&2
  exit 1
fi

git fetch origin "${BRANCH}"
git checkout "${BRANCH}"
git pull --ff-only origin "${BRANCH}"

export SUB2API_COMMIT
SUB2API_COMMIT="$(git rev-parse --short HEAD)"

docker compose --env-file "${ENV_FILE}" -f "${COMPOSE_FILE}" build --pull sub2api
docker compose --env-file "${ENV_FILE}" -f "${COMPOSE_FILE}" up -d --remove-orphans
docker compose --env-file "${ENV_FILE}" -f "${COMPOSE_FILE}" ps
