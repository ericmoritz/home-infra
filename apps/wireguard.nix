{ pkgs, config, ... }:
{
  age.secrets.wireshark-private-key.file = ../secrets/wireshark-private-key.age;

  networking.firewall = {
    allowedUDPPorts = [ config.networking.wg-quick.interfaces.wg0.listenPort ];
  };

  # Enable wg-quick
  networking.wg-quick.interfaces = {
    wg0 = {
      address = [ "10.2.0.2/32" ];

      # use dnscrypt, or proxy dns as described above
      dns = [ "10.2.0.1" ];

      privateKeyFile = config.age.secrets.wireshark-private-key.path;

      listenPort = 51820;

      peers = [
        #US-NJ#236
        {

          # Public key of the server (not a file path).
          publicKey = "FSoutl7ON0IAx+mtpb3bBVScZWyh4G6ihA1jAVkggA0=";

          # Forward all the traffic via VPN.
          allowedIPs = [
            "0.0.0.0/0"
            "::/0"
          ];

          # Set this to the server IP and port.
          endpoint = "151.243.141.4:51820";

        }
      ];
    };
  };

}
