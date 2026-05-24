#!/usr/bin/env bash
set -Eeuo pipefail

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PULL_RETRIES="${PULL_RETRIES:-5}"
PULL_SLEEP_SECONDS="${PULL_SLEEP_SECONDS:-15}"

log() { printf '[INFO] %s\n' "$*"; }
warn() { printf '[WARN] %s\n' "$*" >&2; }
die() { printf '[ERROR] %s\n' "$*" >&2; exit 1; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"
}

pull_with_retry() {
  local image="$1"
  local attempt=1
  while [ "$attempt" -le "$PULL_RETRIES" ]; do
    log "Pulling image: ${image} (attempt ${attempt}/${PULL_RETRIES})"
    if docker pull "$image"; then
      log "Pulled successfully: ${image}"
      return 0
    fi
    warn "Pull failed for ${image}"
    attempt=$((attempt + 1))
    sleep "$PULL_SLEEP_SECONDS"
  done
  die "Could not pull ${image}. Check DNS, firewall, proxy, registry access, or Docker Hub auth."
}

wait_http() {
  local name="$1"
  local url="$2"
  local timeout="${3:-180}"
  local start now code

  start="$(date +%s)"
  while true; do
    code="$(curl -ksS --max-time 5 -o /dev/null -w '%{http_code}' "$url" 2>/dev/null || true)"
    if [ "$code" != "000" ] && [ -n "$code" ]; then
      log "${name} answered with HTTP ${code}"
      return 0
    fi

    now="$(date +%s)"
    if [ $((now - start)) -ge "$timeout" ]; then
      warn "${name} did not answer before timeout: ${url}"
      return 1
    fi
    sleep 5
  done
}

deploy_wildfly_sample() {
  log "Deploying sample.war to WildFly through jboss-cli"
  for i in $(seq 1 24); do
    if docker exec mw-wildfly /opt/jboss/wildfly/bin/jboss-cli.sh \
      --connect \
      --controller=127.0.0.1:9990 \
      --user=admin \
      --password=admin123 \
      "deploy /opt/jboss/wildfly/standalone/deployments/sample.war --force" >/dev/null 2>&1; then
      log "WildFly deployment completed"
      return 0
    fi
    sleep 5
  done
  warn "WildFly deployment via CLI failed. Check: docker logs mw-wildfly"
  return 1
}

log "Middleware lab directory: ${LAB_DIR}"

require_cmd docker
require_cmd curl
docker compose version >/dev/null 2>&1 || die "Docker Compose v2 is required."

log "Preparing directories and permissions"
mkdir -p \
  "${LAB_DIR}/logs/wildfly" \
  "${LAB_DIR}/logs/tomcat" \
  "${LAB_DIR}/logs/liberty" \
  "${LAB_DIR}/logs/apache" \
  "${LAB_DIR}/logs/weblogic" \
  "${LAB_DIR}/apps" \
  "${LAB_DIR}/weblogic/properties"

chmod -R 777 "${LAB_DIR}/logs"
chmod -R a+rX "${LAB_DIR}/apps" "${LAB_DIR}/weblogic"
touch "${LAB_DIR}/apps/sample.war.dodeploy"

if [ ! -f "${LAB_DIR}/weblogic/properties/domain.properties" ]; then
  cat > "${LAB_DIR}/weblogic/properties/domain.properties" <<'EOF'
username=weblogic
password=Welcome1
EOF
fi

log "Pulling external runtime images"
pull_with_retry "quay.io/wildfly/wildfly:latest"
pull_with_retry "icr.io/appcafe/open-liberty:full-java17-openj9-ubi"
pull_with_retry "registry.access.redhat.com/ubi9/openjdk-17-runtime:latest"
pull_with_retry "registry.access.redhat.com/ubi9/httpd-24:latest"
pull_with_retry "gstvo2k15/weblogic:12.2.1.4-developer"

log "Rebuilding local images"
cd "${LAB_DIR}"
docker compose build --no-cache tomcat apache

log "Resetting previous containers"
docker compose down --remove-orphans

log "Starting core middleware"
docker compose up -d wildfly tomcat liberty apache

echo -e "\n[INFO] Waiting for core middleware startup"
wait_http "Tomcat" "http://localhost:8081/sample/" 180 || true
wait_http "Liberty" "http://localhost:9080/sample/" 240 || true
wait_http "WildFly admin" "http://localhost:9990/console" 240 || true
deploy_wildfly_sample || true

log "Starting WebLogic separately"
docker compose up -d weblogic || true

echo -e "\n[INFO] Waiting 180 seconds for WebLogic domain creation/startup"
sleep 180

./scripts/status.sh

echo -e "\nMain URLs:"
echo -e "  WildFly app:        http://localhost:8080/sample/"
echo -e "  WildFly admin:      http://localhost:9990/console"
echo -e "  Tomcat app:         http://localhost:8081/sample/"
echo -e "  Open Liberty app:   http://localhost:9080/sample/"
echo -e "  WebLogic admin:     http://localhost:7001/console"
echo -e "  Apache status:      http://localhost:8088/server-status"

echo -e "\nCredentials:"
echo -e "  WildFly:  admin / admin123"
echo -e "  WebLogic: weblogic / Welcome1"
