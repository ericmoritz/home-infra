{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";

    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ]
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.permittedInsecurePackages = [
              "python3.10-certifi-2022.9.24"
              "python2.7-certifi-2021.10.8"
              "python2.7-pyjwt-1.7.1"

            ];
          };
        in
        {
          defaultPackage = pkgs.hello;
          devShell = pkgs.mkShell {
            packages = with pkgs; [
              nixopsUnstable
            ];
          };

        }
      ) // {
      nixopsConfigurations.default = {
        inherit nixpkgs;
        network.storage.legacy = {
          databasefile = "~/.nixops/deployments.nixops";
        };

        k3s-master = { config, pkgs, ... }:
          {
            deployment.targetHost = "192.168.1.3";

            imports = [
              ./nixos/thinkserver/configuration.nix
            ];
            services.k3s.enable = true;

            networking.firewall = {
              allowedTCPPorts = [
                22 # ssh
                6443 #
                10250 #
                31248 # deluge
                9600 # assetto server
                8772 # assetto web
                8081 # assetto api
                51820
              ];

              allowedUDPPorts = [
                9600 # assetto server
                51820
              ];
            };
            networking.hostName = "k3s-master";

            # must run `ip route add 185.156.46.33 via 192.168.1.1` in order to be
            # able to connect to the VPN
            # networking.wireguard.interfaces = {
            #   wg0 = {
            #     ips = [ "10.2.0.2/32" ];
            #     listenPort = 51820;
            #     privateKeyFile = "/root/wireguard-keys/private";

            #     peers = [
            #       {
            #         publicKey = "zAIZj//t14xuriUMSlWk4/J2jox6I/JMzHL1Y3D/WUE=";
            #         allowedIPs = [ "0.0.0.0/0" ];
            #         endpoint = "185.156.46.33:51820";
            #         persistentKeepalive = 25;
            #       }
            #     ];
            #   };
            # };

            environment.systemPackages = with pkgs; [
              vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
              nfs-utils
              # libnatpmp
            ];

            fileSystems."/mnt/k8s" = {
              device = "192.168.1.2:/volume1/k8s";
              fsType = "nfs";
            };

          };
      };
    };
}
