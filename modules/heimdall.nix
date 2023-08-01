{ config, lib, ... }:
with lib;
let
  version = "2.4.15";
  cfg = config.services.heimdallContainer;
in
{
  options.services.heimdallContainer = {
    enable = mkEnableOption "enable Heimdall";
    configPath = mkOption {
      type = types.str;
      default = "/var/lib/heimdall/.config";
      description = mdDoc "path to the heimdall config (make sure the uid can write to this path)";
    };

    port = mkOption {
      type = types.port;
      default = 8080;
      description = mdDoc "Local port to bind to";
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
  };

  config = mkIf cfg.enable
    {
      virtualisation.oci-containers.containers.heimdall = {
        image = "linuxserver/heimdall:${version}";
        ports = [ "${toString cfg.port}:80" ];
        volumes = [ "${cfg.configPath}:/config" ];
        environment = {
          PGID = toString cfg.gid;
          PUID = toString cfg.uid;
          TZ = "America/New_York";
        };
      };
    };
}
