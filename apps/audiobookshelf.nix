{
  media-repo,
  acmeHost,
  hostname,
}:
{ config, ... }: {
  services.audiobookshelf = {
    enable = true;
    user = "dl";
    group = "users";
  };

  services.nginx.virtualHosts.${hostname} = {
    forceSSL = true;
    useACMEHost = acmeHost;

    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.audiobookshelf.port}/";
      proxyWebsockets = true;
      extraConfig = ''
        client_max_body_size 1000m;
      '';
    };
  };
}
