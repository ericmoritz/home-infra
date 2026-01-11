{
  config,
  pkgs,
  ...
}:
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

  # needed for mdns and zeroconf
  services.avahi.enable = true;

  services.home-assistant = {
    enable = true;

    # See <https://github.com/NixOS/nixpkgs/blob/nixos-25.11/pkgs/servers/home-assistant/component-packages.nix>
    # for a list of component names
    extraComponents = [
      "accuweather"
      "analytics"
      "backup"
      "caldav"
      "calendar"
      "camera"
      "cast"
      "default_config"
      "esphome"
      "ffmpeg"
      "google"
      "google_assistant"
      "google_assistant_sdk"
      "google_photos"
      "google_translate"
      "google_travel_time"
      "here_travel_time"
      "isal"
      "jellyfin"
      "lg_thinq"
      "met"
      "mqtt"
      "mqtt_room"
      "nest"
      "radio_browser"
      "remote_calendar"
      "shopping_list"
      "waze_travel_time"
      "wiz"
    ];

    extraPackages =
      ps: with ps; [
        grpcio
        getmac
        aioharmony
        zeroconf
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
        (import ./automations/update_eric_to_corsha_travel_time.nix)
      ];
    };
  };
}
