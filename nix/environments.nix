# prod/stg のシークレット（DB パスワード等）は sops 経由で注入するため
# ここにはプレースホルダーか非機密値のみ記載する
{
  dev = {
    APP_ENV = "development";
    LOG_LEVEL = "debug";
    DATABASE_HOST = "127.0.0.1";
    DATABASE_PORT = "5432";
    DATABASE_NAME = "app_dev";
    DATABASE_USER = "postgres";
    DATABASE_SSLMODE = "disable";
    SERVER_PORT = "8080";
  };

  stg = {
    APP_ENV = "staging";
    LOG_LEVEL = "info";
    DATABASE_HOST = "stg-db.internal";
    DATABASE_PORT = "5432";
    DATABASE_NAME = "app_stg";
    DATABASE_USER = "myapp";
    DATABASE_SSLMODE = "require";
    SERVER_PORT = "8080";
  };

  prod = {
    APP_ENV = "production";
    LOG_LEVEL = "warn";
    DATABASE_HOST = "prod-db.internal";
    DATABASE_PORT = "5432";
    DATABASE_NAME = "app_prod";
    DATABASE_USER = "myapp";
    DATABASE_SSLMODE = "require";
    SERVER_PORT = "8080";
  };
}
