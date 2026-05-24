#!/usr/bin/env bash
set -Eeuo pipefail
LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${LAB_DIR}"
svc="${1:-}"
if [ -n "$svc" ]; then
  docker compose logs -f --tail=200 "$svc"
else
  docker compose logs -f --tail=200
fi
