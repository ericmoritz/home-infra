{ config, pkgs, ... }:
{

  age.secrets.mqtt-ha-passwd.file = ../secrets/mqtt-ha-password.age;

  networking.firewall.allowedTCPPorts = [ 1883 ];

  services.mosquitto = {
    enable = true;
    listeners = [
      {
        users.hass = {
          acl = [ "readwrite #" ];
          hashedPasswordFile = config.age.secrets.mqtt-ha-passwd.path;
        };
      }
    ];
  };
}
