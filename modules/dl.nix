{ config, lib, ... }:
with lib;
let
  cfg = config.services.dlServices;
in
{
  options.services.dlServices = {
    enable = mkEnableOption "enable download services";
    media-repo = mkOption {
      type = types.str;
      default = "/mnt/k8s/media-repo";
      description = mdDoc "root directory for the download services";
    };

    uid = mkOption {
      type = types.int;
      default = 1032;
      description = mdDoc "UID for the heimdall user";
    };

    gid = mkOption {
      type = types.int;
      default = 100;
      description = mdDoc "UID for the heimdall user";
    };

    ports =
      {
        sonarr = mkOption {
          type = types.port;
          default = 7878;
          description = mdDoc "Local port to bind to";
        };
        radarr = mkOption {
          type = types.port;
          default = 8989;
          description = mdDoc "Local port to bind to";
        };
        sabnzbd = mkOption {
          type = types.port;
          default = 9898;
          description = mdDoc "Local port to bind to";
        };
        deluge = {
          http = mkOption {
            type = types.port;
            default = 8112;
            description = mdDoc "HTTP port for deluge";
          };
          bt = mkOption {
            type = types.port;
            default = 8112;
            description = mdDoc "Bittorrent port for deluge";
          };

        };
      };
  };

  config = mkIf cfg.enable
    {
      virtualisation.oci-containers.containers =
        with cfg;
        {
          radarr = {
            image = "linuxserver/radarr:4.3.2";
            ports = [ "${toString ports.radarr}:7878" ];
            volumes = [
              "${media-repo}/radarr-config:/config"
              "${media-repo}/movies:/movies"
              "${media-repo}/downloads:/downloads"
            ];
            environment = {
              PGID = toString gid;
              PUID = toString uid;
              TZ = "America/New_York";
            };
          };

          sonarr = {
            image = "linuxserver/sonarr:3.0.9";
            ports = [ "${toString ports.sonarr}:8989" ];
            volumes = [
              "${media-repo}/sonarr-config:/config"
              "${media-repo}/tv:/tv"
              "${media-repo}/downloads:/downloads"
            ];
            environment = {
              PGID = toString gid;
              PUID = toString uid;
              TZ = "America/New_York";
            };
          };

          sabnzbd = {
            image = "linuxserver/sabnzbd:3.7.2";
            ports = [ "${toString ports.sabnzbd}:8989" ];
            volumes = [
              "${media-repo}/sabnzbd-config:/config"
              "${media-repo}/downloads:/downloads"
              "${media-repo}/incomplete-downloads:/incomplete-downloads"
            ];
            environment = {
              PGID = toString gid;
              PUID = toString uid;
              TZ = "America/New_York";
            };
          };

          deluge = {
            image = "linuxserver/deluge:2.0.5";
            ports = [
              "${toString ports.deluge.http}:8112"
              "${toString ports.deluge.bt}:31248"
            ];
            volumes = [
              "${media-repo}/deluge-config:/config"
              "${media-repo}/downloads:/downloads"
              "${media-repo}/incomplete-downloads:/incomplete-downloads"
            ];
            environment = {
              PGID = toString gid;
              PUID = toString uid;
              TZ = "America/New_York";
            };
          };
        };
    };
}
