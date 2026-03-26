{ pkgs, lib, config, ... }:

{
  # Go
  languages.go = {
    enable = true;
    package = pkgs.go_1_26;
  };

  # 開発ツール
  packages = with pkgs; [
    git
    goose # マイグレーション
    sqlc # SQL → Go コード生成
    postgresql # psql クライアント
    oapi-codegen #OpenAPI → Goコード生成
  ];

  # PostgreSQL サービス
  services.postgres = {
    enable = true;
    package = pkgs.postgresql_16;
    listen_addresses = "127.0.0.1";
    port = 5432;

    initialDatabases = [
      { name = "my_dev"; }
    ];

    # データは .devenv/state/postgres 以下に永続化される
    settings = {
      log_statement = "all"; # 開発中は全クエリログ
      log_min_duration_statement = 0;
    };
  };

  # 環境変数（アプリから参照）
  env = {
    DATABASE_URL = "postgresql://localhost:5432/my_dev?sslmode=disable";
  };

  # シェルに入ったときのフック
  enterShell = ''
    echo "=== Dev Environment ==="
    echo "Go:       $(go version)"
    echo "DB:       $DATABASE_URL"
    echo ""
    echo "devenv up  → PostgreSQL 起動"
    echo "psql my_dev → DB 接続"
  '';

  # プロセス管理（devenv up で起動）
  # PostgreSQL は services.postgres.enable で自動登録されるため
  # 追加のプロセスがあればここに定義
  # processes.api.exec = "go run ./cmd/api";
}
