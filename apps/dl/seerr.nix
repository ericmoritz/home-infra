# Adapted from https://github.com/NixOS/nixpkgs/pull/450093
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.seerr;
in
{
  options.services.seerr = with lib; {
    enable = mkEnableOption "Seerr, a requests manager for Jellyfin";

    image = mkOption {
      type = types.str;
      default = "ghcr.io/seerr-team/seerr:v3.1.0";
      description = "docker image to use";
    };

    port = mkOption {
      type = types.port;
      default = 5055;
      description = "The port which the Seerr web UI should listen to.";
    };

    configDir = mkOption {
      type = types.path;
      default = "/var/lib/seerr/config";
      description = "Config data directory";
    };

    user = mkOption {
      type = types.str;
      default = "dl";
      description = "User account under which Seerr runs.";
    };

    group = mkOption {
      type = types.str;
      default = "users";
      description = "Group under which Seerr runs.";
    };

    virtualHost = mkOption {
      type = types.str;
      default = "requests.home.ericcodes.io";
      description = ''
        Name of the caddy/nginx virtualhost to use and setup.
      '';
    };

    useACMEHost = mkOption {
      type = types.str;
      default = "home.ericcodes.io";
      description = ''
        If set, use NixOS-generated ACME certificate with the specified name for TLS.

        Note that it requires {option}`security.acme` to be setup, e.g., credentials provided if using DNS-01 validation.
      '';
    };

  };

  config =
    with cfg;
    lib.mkIf enable {

      virtualisation.oci-containers.containers.seerr = {
        inherit image;

        ports = [
          "${toString cfg.port}:${toString cfg.port}"
        ];

        environment = {
          TZ = "America/New_York";
          PORT = toString port;
        };

        volumes = [
          "${cfg.configDir}:/app/config"
        ];
      };

      services.nginx.virtualHosts.${virtualHost} = {
        forceSSL = true;
        inherit (cfg) useACMEHost;

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString port}/";
          proxyWebsockets = true;
        };
      };

      # Ensure the configDir exists and is owned by the user
      systemd.tmpfiles.rules = [
        "d ${configDir} 0777 ${user} ${group}"
      ];
    };
}
