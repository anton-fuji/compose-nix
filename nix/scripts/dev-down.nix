{ pkgs }:

let
  envTarget =
    let e = builtins.getEnv "APP_ENV";
    in if e == "" then "dev" else e;
  prefix = "composenix-${envTarget}";
in
pkgs.writeShellScriptBin "dev-down" ''
  set -euo pipefail

  echo "=== compose-nix: stopping ${envTarget} ==="

  # コンテナ停止・削除
  for c in $(docker ps -aq --filter "name=${prefix}"); do
    docker rm -f "$c"
  done

  # ネットワーク削除
  docker network rm ${prefix} 2>/dev/null || true

  echo "Done. Volumes are preserved (use docker volume prune to clean)."
''
