{ pkgs, environments, envTarget }:

let
  envVars = environments.${envTarget};

  app = pkgs.buildGoModule {
    pname = "myapp";
    version = "0.1.0";
    src = builtins.path {
      path = ../../src;
      name = "myapp-src";
    };
    # go.sum から算出されるハッシュ（初回は lib.fakeHash で取得）
    vendorHash = null;
    subPackages = [ "cmd/api" ];
    CGO_ENABLED = 0;
    ldflags = [
      "-s"
      "-w"
      "-X main.version=0.1.0"
      "-X main.env=${envTarget}"
    ];
  };
in
pkgs.dockerTools.buildLayeredImage {
  name = "myapp";
  tag = envTarget;

  contents = [
    app
    pkgs.cacert # TLS 証明書
    pkgs.tzdata # タイムゾーン
  ];

  # レイヤー数の上限（デフォルト 100）
  maxLayers = 50;

  config = {
    Cmd = [ "${app}/bin/api" ];
    ExposedPorts = {
      "${envVars.SERVER_PORT}/tcp" = { };
    };
    Env = [
      "TZ=Asia/Tokyo"
      "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
    ];
    # コンテナ内で root 以外で実行
    User = "1000:1000";
  };
}
