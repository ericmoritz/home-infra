{ config, pkgs, ... }:
{
  age.secrets.acme-env.file = ../secrets/acme-env.age;

  users.users.nginx.extraGroups = [ "acme" ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "eric@ericcodes.io";
    certs."home.ericcodes.io" = {
      domain = "*.home.ericcodes.io";
      dnsProvider = "gandiv5";
      environmentFile = config.age.secrets.acme-env.path;
      dnsPropagationCheck = true;
    };
  };
}
