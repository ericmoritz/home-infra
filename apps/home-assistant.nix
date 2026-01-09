{ config, pkgs, ... }:
let
  hostname = "hass.home.ericcodes.io";
  acmeHost = "home.ericcodes.io";
  server_port = config.services.home-assistant.config.http.server_port;
in
{
  services.nginx.virtualHosts.${hostname} = {
    forceSSL = true;
    useACMEHost = acmeHost;

    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString server_port}/";
      proxyWebsockets = true;
    };
  };

  environment.systemPackages = with pkgs; [
    ffmpeg
  ];

  services.home-assistant = {
    enable = true;

    extraComponents = [
      "default_config"
      "esphome"
      "met"
      "radio_browser"
      "ffmpeg"
    ];
    extraPackages =
      ps: with ps; [
        pywizlight
        google-nest-sdm
        grpcio
        securetar
        getmac
        aioharmony
      ];

    config = {
      default_config = { };
      http = {
        use_x_forwarded_for = true;
        trusted_proxies = "127.0.0.1";
      };

      automation = [
        {
          alias = "Backup Home Assistant every night at 3 AM";
          trigger = {
            platform = "time";
            at = "03:00:00";
          };
          action = {
            alias = "Create backup now";
            service = "backup.create";
          };
        }
      ];
    };
  };
}
