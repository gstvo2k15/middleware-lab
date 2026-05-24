#!/usr/bin/env bash
set -Eeuo pipefail

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${LAB_DIR}"

echo -e "\n===== Docker Compose Status ====="
docker compose ps

echo -e "\n===== Health Checks ====="

check() {
  local name="$1"
  local url="$2"
  local code

  code="$(curl -ksS --max-time 5 -o /dev/null -w '%{http_code}' "${url}" 2>/dev/null || true)"

  if [ -z "$code" ] || [ "$code" = "000" ]; then
    code="000"
  fi

  printf '%-18s %s %s\n' "${name}" "${code}" "${url}"
}

check "WildFly" "http://localhost:8080/sample/"
check "WildFly admin" "http://localhost:9990/console"
check "Tomcat" "http://localhost:8081/sample/"
check "Liberty" "http://localhost:9080/sample/"
check "WebLogic" "http://localhost:7001/console"
check "Apache" "http://localhost:8088/server-status"
check "Apache Tomcat" "http://localhost:8088/tomcat/sample/"
check "Apache WildFly" "http://localhost:8088/wildfly/sample/"
check "Apache Liberty" "http://localhost:8088/liberty/sample/"
check "Apache WebLogic" "http://localhost:8088/weblogic/"
check "WebLogic MS1 sample" "http://localhost:8001/sample/"
check "WebLogic MS2 sample" "http://localhost:8002/sample/"
check "Apache WLS Console" "http://localhost:8088/console/"
check "Apache WLS Cluster" "http://localhost:8088/wlscluster/sample/"