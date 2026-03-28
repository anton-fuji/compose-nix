{ pkgs, images, environments, envTarget, lib' }:

let
  env = environments.${envTarget};
  dbUrl = lib'.buildDatabaseUrl env;
  net = lib'.networkName envTarget;
  name = svc: lib'.containerName svc envTarget;
in
pkgs.writeShellScriptBin "dev-up" ''
  set -euo pipefail

  echo "=== compose-nix: ${envTarget} ==="

  echo "[1/4] Loading images..."
  docker load < ${images.app}
  docker load < ${images.migrator}

  echo "[2/4] Creating network..."
  docker network create ${net} 2>/dev/null || true

  # PostgreSQL
  echo "[3/4] Starting PostgreSQL..."
  docker rm -f ${name "db"} 2>/dev/null || true
  docker run -d \
    --name ${name "db"} \
    --network ${net} \
    -v ${name "pgdata"}:/var/lib/postgresql/data \
    -e POSTGRES_DB=${env.DATABASE_NAME} \
    -e POSTGRES_HOST_AUTH_METHOD=trust \
    --health-cmd "pg_isready -U postgres" \
    --health-interval 2s \
    --health-retries 10 \
    postgres:16

  echo "    Waiting for PostgreSQL..."
  until docker inspect --format='{{.State.Health.Status}}' ${name "db"} 2>/dev/null | grep -q healthy; do
    sleep 1
  done

  echo "    Running migrations..."
  docker run --rm \
    --network ${net} \
    ${images.migrator.imageName}:${images.migrator.imageTag} \
    "${dbUrl}" up

  echo "[4/4] Starting app..."
  docker rm -f ${name "app"} 2>/dev/null || true
  docker run -d \
    --name ${name "app"} \
    --network ${net} \
    ${lib'.envToFlags env} \
    -e DATABASE_URL="${dbUrl}" \
    -p ${env.SERVER_PORT}:${env.SERVER_PORT} \
    ${images.app.imageName}:${images.app.imageTag}

  echo ""
  echo "Ready: http://localhost:${env.SERVER_PORT}"
  echo "Logs:  docker logs -f ${name "app"}"
''
