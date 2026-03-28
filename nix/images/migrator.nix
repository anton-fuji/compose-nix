{ pkgs }:

let
  migrations = builtins.path {
    path = ../../sql/schema;
    name = "migrations";
  };
in
pkgs.dockerTools.buildLayeredImage {
  name = "myapp-migrator";
  tag = "latest";

  contents = [
    pkgs.goose
    pkgs.cacert
  ];

  config = {
    Entrypoint = [
      "${pkgs.goose}/bin/goose"
      "-dir"
      "${migrations}"
      "postgres"
    ];
    # DATABASE_URL は実行時に -e で渡す
    Env = [
      "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
    ];
    User = "1000:1000";
  };
}
