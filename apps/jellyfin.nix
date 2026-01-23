{ pkgs, config, ... }:
let
  hostname = "jellyfin.home.ericcodes.io";
  port = "8096";
  acmeHost = "home.ericcodes.io";
in
{
  networking.firewall.allowedUDPPorts = [
    1900
    7359
  ];

  services.jellyfin = {
    user = "dl";
    group = "users";
    enable = true;
  };

  services.nginx.virtualHosts.${hostname} = {
    forceSSL = true;
    useACMEHost = acmeHost;

    locations."/" = {
      proxyPass = "http://127.0.0.1:${port}/";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
  };
}
