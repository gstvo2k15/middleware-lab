#!/usr/bin/env bash
set -Eeuo pipefail
IMAGE="gstvo2k15/weblogic:12.2.1.4-developer"

echo -e "\n===== Host memory ====="
free -h || true

echo -e "\n===== Host ulimit ====="
ulimit -a || true

echo -e "\n===== Image command ====="
docker inspect "${IMAGE}" --format='Entrypoint={{json .Config.Entrypoint}} Cmd={{json .Config.Cmd}} User={{json .Config.User}}'

echo -e "\n===== Recent container state ====="
docker ps -a --filter name=mw-weblogic

echo -e "\n===== Recent logs ====="
docker logs --tail=200 mw-weblogic 2>/dev/null || true

echo -e "\n===== Important files inside image ====="
docker run --rm --entrypoint bash "${IMAGE}" -lc '
id || true
ls -l /u01/oracle || true
echo
echo "--- createAndStartEmptyDomain.sh ---"
sed -n "1,240p" /u01/oracle/createAndStartEmptyDomain.sh || true
echo
echo "--- create-wls-domain.py ---"
sed -n "1,280p" /u01/oracle/create-wls-domain.py || true
'
