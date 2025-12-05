{ pkgs, config, ... }:
let
  media-repo = "/mnt/k8s/media-repo";
  apps = {
    sabnzbd = {
      hostname = "nzb.home.ericcodes.io";
      port = "8001";
    };
    sonarr = {
      hostname = "sonarr.home.ericcodes.io";
      port = toString config.services.sonarr.settings.server.port;
    };
    radarr = {
      hostname = "radarr.home.ericcodes.io";
      port = toString config.services.radarr.settings.server.port;
    };
    slskd = { hostname = "soulseek.home.ericcodes.io"; };
  };
in {
  age.secrets.slskd-env.file = ../secrets/slskd-env.age;

  users.users.dl = {
    uid = 1032;
    group = "users";
    isNormalUser = true;
  };

  ####
  ## Sonarr
  ####
  services.sonarr = {
    enable = true;
    user = "dl";
    group = "users";
    dataDir = "${media-repo}/sonarr-config";
  };

  services.nginx.virtualHosts.${apps.sonarr.hostname} = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${apps.sonarr.port}/";
      proxyWebsockets = true;
    };
  };

  ####
  ## Radarr
  ####
  services.radarr = {
    enable = true;
    user = "dl";
    group = "users";
    dataDir = "${media-repo}/radarr-config";
  };

  services.nginx.virtualHosts.${apps.radarr.hostname} = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${apps.radarr.port}/";
      proxyWebsockets = true;
    };
  };

  ####
  ## Sabnzbd
  ####
  services.sabnzbd = {
    enable = true;
    configFile = "${media-repo}/sabnzbd-config/sabnzbd.ini";
    user = "dl";
    group = "users";
  };

  services.nginx.virtualHosts.${apps.sabnzbd.hostname} = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${apps.sabnzbd.port}/";
      proxyWebsockets = true;
    };
  };

  ####
  ## slskd
  ####
  services.slskd = {
    enable = true;
    user = "dl";
    group = "users";
    domain = apps.slskd.hostname;
    environmentFile = config.age.secrets.slskd-env.path;
    settings = {
      shares.directories = [ "${media-repo}/music/eric-Music/" ];
      directories.incomplete = "${media-repo}/incomplete-downloads";
      directories.downloads = "${media-repo}/downloads";
    };
  };
}
