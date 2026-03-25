{ pkgs, ... }:
let
  dbName = "mydb";
  dbUser = "appuser";
  dbPass = "password";
  dbPort = "5432";
in
{
  services = {
    app.service = {
      image = "go-app:1.26.1";
      ports = [ "8000:8000" ];
      environment = {
        DATABASE_URL = "postgres://${dbUser}:${dbPass}@db:${dbPort}/${dbName}";
      };
      depends_on = [ "db" ];
      restart = "on-failure";
    };

    db.service = {
      image = "postgres:15";
      ports = [ "${dbPort}:${dbPort}" ];
      environment = {
        POSTGRES_DB = dbName;
        POSTGRES_USER = dbUser;
        POSTGRES_PASSWORD = dbPass;
      };
      volumes = [ "pgdata:/var/lib/postgresql/data" ];
    };
  };

  docker-compose.volumes.pgdata = { };
}

