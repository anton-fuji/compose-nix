{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    arion.url = "github:hercules-ci/arion";
  };
  outputs = { self, nixpkgs, arion }:
    let
      pkgsLinux = nixpkgs.legacyPackages.x86_64-linux;
      pkgsDarwin = nixpkgs.legacyPackages.aarch64-darwin;
    in
    {
      # Linuxビルド（Docker用）
      packages.x86_64-linux.default = pkgsLinux.buildGoModule {
        name = "go-app";
        src = ./.;
        vendorHash = null;
      };

      packages.x86_64-linux.docker = pkgsLinux.dockerTools.buildImage {
        name = "go-app";
        tag = "latest";
        copyToRoot = [ self.packages.x86_64-linux.default ];
        config = {
          Cmd = [ "/bin/go-app" ];
          ExposedPorts."8000/tcp" = { };
        };
      };

      apps.x86_64-linux.arion = arion.apps.x86_64-linux.arion;

      # Mac用devShell
      devShells.aarch64-darwin.default = pkgsDarwin.mkShell {
        packages = [
          pkgsDarwin.go
          pkgsDarwin.git
          arion.packages.aarch64-darwin.arion
        ];
      };
    };
}
