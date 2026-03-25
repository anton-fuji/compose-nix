{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    arion.url = "github:hercules-ci/arion";
  };
  outputs = { self, nixpkgs, arion }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in
    {
      packages.x86_64-linux.default = pkgs.buildGoModule {
        name = "go-app";
        src = ./.;
        vendorHash = null;
      };

      packages.x86_64-linux.docker = pkgs.dockerTools.buildImage {
        name = "go-app";
        tag = "latest";
        copyToRoot = [ self.packages.x86_64-linux.default ];
        config = {
          Cmd = [ "/bin/go-app" ];
          ExposedPorts."8000/tcp" = { };
        };
      };

      apps.x86_64-linux.arion = arion.apps.x86_64-linux.arion;

      devShells.x86_64-linux.default = pkgs.mkShell {
        packages = [ pkgs.go ];
      };
    };
}
