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
        thinqconnect
        paho-mqtt
      ];

    config = {
      default_config = { };
      http = {
        use_x_forwarded_for = true;
        trusted_proxies = "127.0.0.1";
      };

      automation = [
        {
          alias = "Washer Done";
          triggers = [
            {
              trigger = "state";
              entity_id = "sensor.washer_current_status";
              to = "end";
            }
          ];
          actions = [
            {
              action = "notify.notify";
              data = {
                message = "Washer Done";
              };
            }
          ];
        }
        {
          alias = "Dryer Done";
          triggers = [
            {
              trigger = "state";
              entity_id = "sensor.dryer_current_status";
              to = "end";
            }
          ];
          actions = [
            {
              action = "notify.notify";
              data = {
                message = "Dryer Done";
              };
            }
          ];
        }
      ];
    };
  };
}
