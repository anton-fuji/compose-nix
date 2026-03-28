{ pkgs, images, environments, envTarget }:

let
  lib' = import ../lib.nix { inherit pkgs; lib = pkgs.lib; };
  env = environments.${envTarget};
  dbUrl = lib'.buildDatabaseUrl env;
  net = lib'.networkName envTarget;
in
pkgs.writeShellScriptBin "migrate" ''
  set -euo pipefail

  CMD="''${1:-up}"

  echo "=== Migration: $CMD (${envTarget}) ==="

  docker run --rm \
    --network ${net} \
    ${images.migrator.imageName}:${images.migrator.imageTag} \
    "${dbUrl}" "$CMD"
''
