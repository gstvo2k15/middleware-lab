#!/usr/bin/env bash
set -Eeuo pipefail

TARGET="${1:-all}"

java_pid() {
  docker exec "$1" sh -lc 'jps 2>/dev/null | awk "/Jps/ {next} {print \$1; exit}" || true'
}

dump_java() {
  local container="$1"
  local pid

  echo -e "\n========== ${container}: processes =========="
  docker exec "${container}" sh -lc 'jps -lv 2>/dev/null || ps -ef' || true

  pid="$(java_pid "${container}")"
  if [ -z "$pid" ]; then
    echo -e "\n========== ${container}: no Java PID detected =========="
    return 0
  fi

  echo -e "\n========== ${container}: detected Java PID =========="
  echo "${pid}"

  echo -e "\n========== ${container}: JVM flags =========="
  docker exec "${container}" sh -lc "jcmd ${pid} VM.flags 2>/dev/null || true"

  echo -e "\n========== ${container}: heap =========="
  docker exec "${container}" sh -lc "jcmd ${pid} GC.heap_info 2>/dev/null || true"

  echo -e "\n========== ${container}: threads =========="
  docker exec "${container}" sh -lc "jcmd ${pid} Thread.print 2>/dev/null | head -300 || true"
}

case "${TARGET}" in
  wildfly) dump_java mw-wildfly ;;
  tomcat) dump_java mw-tomcat ;;
  liberty) dump_java mw-liberty ;;
  weblogic) dump_java mw-weblogic ;;
  all)
    echo -e "\n===== Middleware JVM Diagnostics ====="
    for c in mw-wildfly mw-tomcat mw-liberty mw-weblogic; do
      if docker ps -a --format '{{.Names}}' | grep -qx "$c"; then
        dump_java "$c" || true
      else
        echo -e "\n========== ${c}: container not found =========="
      fi
    done
    ;;
  *)
    echo "Usage: $0 [all|wildfly|tomcat|liberty|weblogic]"
    exit 1
    ;;
esac
