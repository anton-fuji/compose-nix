{ pkgs, lib }:
{
  # attrset → docker run の -e フラグ列に変換
  envToFlags = envVars:
    lib.concatStringsSep " "
      (lib.mapAttrsToList (k: v: ''-e "${k}=${v}"'') envVars);

  # attrset → DATABASE_URL を組み立て
  buildDatabaseUrl = env:
    "postgresql://${env.DATABASE_USER}@${env.DATABASE_HOST}:${env.DATABASE_PORT}/${env.DATABASE_NAME}?sslmode=${env.DATABASE_SSLMODE}";

  # コンテナ名にプレフィックスを付ける
  containerName = service: envTarget:
    "composenix-${envTarget}-${service}";

  networkName = envTarget:
    "composenix-${envTarget}";
}
