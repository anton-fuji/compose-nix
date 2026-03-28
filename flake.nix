{
  description = "compose-nix: Nix-driven container orchestration for Go + PostgreSQL";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # 環境定義の読み込み
        environments = import ./nix/environments.nix;
        lib' = import ./nix/lib.nix { inherit pkgs; lib = pkgs.lib; };

        # 環境名の解決: APP_ENV 未指定なら dev
        envTarget =
          let e = builtins.getEnv "APP_ENV";
          in if e == "" then "dev" else e;

        # コンテナイメージ
        images = {
          app = import ./nix/images/app.nix {
            inherit pkgs environments envTarget;
          };
          migrator = import ./nix/images/migrator.nix {
            inherit pkgs;
          };
        };

        #  Script
        scripts = {
          dev-up = import ./nix/scripts/dev-up.nix {
            inherit pkgs images environments envTarget lib';
          };
          dev-down = import ./nix/scripts/dev-down.nix {
            inherit pkgs;
          };
          migrate = import ./nix/scripts/migrate.nix {
            inherit pkgs images environments envTarget;
          };
        };
      in
      {
        # nix build .#app-image
        packages = {
          app-image = images.app;
          migrator-image = images.migrator;
          default = images.app;
        };

        # nix run .#dev-up
        apps = builtins.mapAttrs
          (_: script: {
            type = "app";
            program = "${script}/bin/${script.name}";
          })
          scripts;
      }
    );
}
