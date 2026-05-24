#!/usr/bin/env bash
set -Eeuo pipefail
LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${LAB_DIR}"
docker compose down --remove-orphans
