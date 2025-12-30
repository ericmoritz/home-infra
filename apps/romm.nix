{ pkgs, config, ... }:
let
  media-repo = "/mnt/k8s/media-repo";
  hostname = "roms.home.ericcodes.io";
  port = "8002";
  acmeHost = "home.ericcodes.io";
  # version = "sha256:b909e95d1aab88db9817be700183fda8d24094b3e7c28355ddbd066e2659fc8f";
  version = "4.5.0";
  rip-myrient = pkgs.writeScriptBin "rip-myrient" ''
    set -eu
    ${pkgs.wget}/bin/wget -m -np -c -e robots=off -R "index.html*" $@
  '';
in
{

  environment.systemPackages = [
    rip-myrient
  ];
  age.secrets.romm-env.file = ../secrets/romm-env.age;

  virtualisation.oci-containers.containers.romm = {
    image = "rommapp/romm:${version}";
    user = toString config.users.users.dl.uid;
    ports = [
      "${port}:8080"
    ];
    environment = {
      ROMM_DB_DRIVER = "postgresql";
      DB_HOST = "host.docker.internal";
      DB_PORT = "5432";
      DB_NAME = "romm";
      DB_USER = "romm";
      HASHEOUS_API_ENABLED = "true";
      PLAYMATCH_API_ENABLED = "true";
      HLTB_API_ENABLED = "true";
      ENABLE_RESCAN_ON_FILESYSTEM_CHANGE = "true";
      ENABLE_SCHEDULED_RESCAN = "true";
      LAUNCHBOX_API_ENABLED = "true";
      ENABLE_SCHEDULED_UPDATE_LAUNCHBOX_METADATA = "true";
    };
    environmentFiles = [
      config.age.secrets.romm-env.path
    ];

    volumes = [
      "${media-repo}/romm/resources:/romm/resources"
      "${media-repo}/romm/redis-data:/redis-data"
      "${media-repo}/romm/library:/romm/library"
      "${media-repo}/romm/assets:/romm/assets"
      "${media-repo}/romm/config:/romm/config"
    ];
  };

  services.nginx.virtualHosts.${hostname} = {
    forceSSL = true;
    useACMEHost = acmeHost;

    locations."/" = {
      proxyPass = "http://127.0.0.1:${port}/";
      proxyWebsockets = true;
    };
  };
}
