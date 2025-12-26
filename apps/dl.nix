{ pkgs, config, ... }:
let
  media-repo = "/mnt/k8s/media-repo";
  acmeHost = "home.ericcodes.io";
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
    slskd = {
      hostname = "soulseek.home.ericcodes.io";
    };

    transmission = {
      hostname = "torrents.home.ericcodes.io";
      port = toString config.services.transmission.settings.rpc-port;
    };
  };
in
{
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
    forceSSL = true;
    useACMEHost = acmeHost;

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
    forceSSL = true;
    useACMEHost = acmeHost;

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
    forceSSL = true;
    useACMEHost = acmeHost;

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
    nginx = {
      forceSSL = true;
      useACMEHost = acmeHost;
    };
    environmentFile = config.age.secrets.slskd-env.path;
    settings = {
      shares.directories = [ "${media-repo}/music/eric-Music/" ];
      directories.incomplete = "${media-repo}/incomplete-downloads";
      directories.downloads = "${media-repo}/downloads";
    };
  };

  ####
  ## transmission
  ####
  services.transmission = {
    user = "dl";
    group = "users";
    enable = true;
    home = "${media-repo}/transmission";
    settings.rpc-bind-address = "0.0.0.0";
    settings.rpc-whitelist-enabled = false;
    settings.rpc-host-whitelist = apps.transmission.hostname;
    openRPCPort = true;
    openFirewall = true;
  };

  services.nginx.virtualHosts.${apps.transmission.hostname} = {
    forceSSL = true;
    useACMEHost = acmeHost;

    locations."/" = {
      proxyPass = "http://127.0.0.1:${apps.transmission.port}/";
      proxyWebsockets = true;
    };
  };

  ####
  ## TV clean-up script
  ####
  systemd.timers."tv-cleanup" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Unit = "tv-cleanup.service";
    };
  };
  systemd.services."tv-cleanup" = {
    script = ''
      set -eu

      # Delete all episodes older than 6 months
      find ${media-repo}/tv -type f -ctime +185 -print -exec rm {} \;
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
