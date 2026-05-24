#!/usr/bin/env bash
set -Eeuo pipefail

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${LAB_DIR}"

echo -e "\n===== WebLogic cluster setup ====="

if ! docker ps --format '{{.Names}}' | grep -qx mw-weblogic; then
  echo "mw-weblogic is not running"
  exit 1
fi

echo -e "\n[INFO] Running WLST cluster creation"
docker exec mw-weblogic bash -lc '/u01/oracle/oracle_common/common/bin/wlst.sh /u01/oracle/wlst/create-cluster.py'

echo -e "\n[INFO] Starting ManagedServer1"
docker exec -d mw-weblogic bash -lc 'nohup /u01/oracle/user_projects/domains/base_domain/bin/startManagedWebLogic.sh ManagedServer1 t3://localhost:7001 > /tmp/ManagedServer1.out 2>&1 &'

echo -e "\n[INFO] Starting ManagedServer2"
docker exec -d mw-weblogic bash -lc 'nohup /u01/oracle/user_projects/domains/base_domain/bin/startManagedWebLogic.sh ManagedServer2 t3://localhost:7001 > /tmp/ManagedServer2.out 2>&1 &'

echo -e "\n[INFO] Waiting for managed servers"
sleep 120

echo -e "\n[INFO] Deploying sample app to LabCluster"
docker exec mw-weblogic bash -lc '/u01/oracle/oracle_common/common/bin/wlst.sh /u01/oracle/wlst/deploy-sample.py' || true

echo -e "\n[INFO] Managed server quick checks"
docker exec mw-weblogic bash -lc 'curl -s -o /dev/null -w "ManagedServer1 HTTP %{http_code}\n" http://localhost:8001/sample/ || true'
docker exec mw-weblogic bash -lc 'curl -s -o /dev/null -w "ManagedServer2 HTTP %{http_code}\n" http://localhost:8002/sample/ || true'