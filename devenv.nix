{ pkgs, lib, config, ... }:

let
  environments = import ./nix/environments.nix;
  env = environments.dev;
  lib' = import ./nix/lib.nix { inherit pkgs lib; };
in
{
  # Go
  languages.go = {
    enable = true;
    package = pkgs.go_1_26;
  };

  packages = with pkgs; [
    git
    goose
    sqlc
    postgresql
    oapi-codegen
    docker
    sops
  ];

  # PostgreSQL（ローカル開発用、コンテナ外）
  services.postgres = {
    enable = true;
    package = pkgs.postgresql_16;
    listen_addresses = "127.0.0.1";
    port = 5432;
    initialDatabases = [
      { name = env.DATABASE_NAME; }
    ];
    settings = {
      log_statement = "all";
      log_min_duration_statement = 0;
    };
  };

  env = {
    APP_ENV = "development";
    DATABASE_URL = lib'.buildDatabaseUrl env;
    SERVER_PORT = env.SERVER_PORT;
  };

  enterShell = ''
    echo "=== compose-nix dev ==="
    echo "Go:   $(go version)"
    echo "DB:   $DATABASE_URL"
    echo ""
    echo "Commands:"
    echo "  devenv up          → PostgreSQL 起動"
    echo "  nix run .#dev-up   → Docker で全サービス起動"
    echo "  nix run .#dev-down → Docker 停止"
    echo "  nix run .#migrate  → マイグレーション"
  '';
}
