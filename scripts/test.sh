#!/usr/bin/env bash

set -eou pipefail

bash scripts/rollout-preflight.sh
./scripts/test-rollout-programs.sh
docker compose build --pull
docker compose run --rm init
docker compose up --remove-orphans --wait --wait-timeout "${COMPOSE_WAIT_TIMEOUT:-600}"

./scripts/test-runtime-programs.sh
./scripts/test-site.sh
