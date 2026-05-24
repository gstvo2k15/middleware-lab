# Middleware Lab Complete v5

Rocky Linux Docker Compose v2 middleware lab.

## Minimum VM sizing

Recommended for full lab with WebLogic:

```text
RAM: 8 GB minimum
CPU: 4 vCPU recommended
Disk: 30 GB free
```

WebLogic has `mem_limit: 3g`, `shm_size: 1g`, and high `nofile/nproc` ulimits.

## Start clean

```bash
unzip middleware-lab-complete-v5.zip
cd middleware-lab-complete-v5
chmod +x scripts/*.sh
./scripts/start.sh
```

## Credentials

```text
WildFly:  admin / admin123
WebLogic: weblogic / Welcome1
```

## Status

`./scripts/status.sh`

```bash
Example output:

[root@rocky9vm02 middleware-lab-complete-v5]# ./scripts/status.sh

===== Docker Compose Status =====
NAME          IMAGE                                                COMMAND                  SERVICE    CREATED          STATUS          PORTS
mw-apache     local/mw-httpd:ubi9                                  "container-entrypoin…"   apache     12 minutes ago   Up 12 minutes   8443/tcp, 0.0.0.0:8088->8080/tcp, [::]:8088->8080/tcp
mw-liberty    icr.io/appcafe/open-liberty:full-java17-openj9-ubi   "/opt/ol/helpers/run…"   liberty    12 minutes ago   Up 12 minutes   0.0.0.0:9080->9080/tcp, [::]:9080->9080/tcp, 0.0.0.0:9443->9443/tcp, [::]:9443->9443/tcp
mw-tomcat     local/mw-tomcat:10.1.33                              "catalina.sh run"        tomcat     12 minutes ago   Up 12 minutes   8443/tcp, 0.0.0.0:8081->8080/tcp, [::]:8081->8080/tcp
mw-weblogic   gstvo2k15/weblogic:12.2.1.4-developer                "/u01/oracle/createA…"   weblogic   11 minutes ago   Up 11 minutes   0.0.0.0:7001->7001/tcp, [::]:7001->7001/tcp, 0.0.0.0:9002->9002/tcp, [::]:9002->9002/tcp
mw-wildfly    quay.io/wildfly/wildfly:latest                       "/__cacert_entrypoin…"   wildfly    12 minutes ago   Up 12 minutes   0.0.0.0:8080->8080/tcp, [::]:8080->8080/tcp, 0.0.0.0:9990->9990/tcp, [::]:9990->9990/tcp

===== Health Checks =====
WildFly            200 http://localhost:8080/sample/
WildFly admin      302 http://localhost:9990/console
Tomcat             200 http://localhost:8081/sample/
Liberty            200 http://localhost:9080/sample/
WebLogic           302 http://localhost:7001/console
Apache             200 http://localhost:8088/server-status
Apache Tomcat      200 http://localhost:8088/tomcat/sample/
Apache WildFly     200 http://localhost:8088/wildfly/sample/
Apache Liberty     200 http://localhost:8088/liberty/sample/
Apache WebLogic    404 http://localhost:8088/weblogic/
```

## Logs

```bash
./scripts/logs.sh apache
./scripts/logs.sh wildfly
./scripts/logs.sh liberty
./scripts/logs.sh tomcat
./scripts/logs.sh weblogic
```

## Diagnostics

```bash
./scripts/diagnostics.sh all
```

## WebLogic debug

```bash
./scripts/weblogic-debug.sh
```

## Stop

```bash
./scripts/stop.sh
```

## v5 changes

- WebLogic memory/ulimit tuning:
  - `mem_limit: 3g`
  - `shm_size: 1g`
  - `nofile: 65536`
  - `nproc: 16384`
  - `USER_MEM_ARGS=-Xms512m -Xmx1024m`
- WebLogic properties file retained at `/u01/oracle/properties/domain.properties`.
- WildFly password is `admin123`.
- WildFly sample deployment is forced via `jboss-cli.sh`.
- `status.sh` no longer emits duplicated codes such as `404000`.
- Startup waits longer before status checks.
- Static WAR uses an old Java EE compatible `web.xml` for broader container compatibility.
