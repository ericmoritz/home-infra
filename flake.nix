{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    agenix.url = "github:ryantm/agenix";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      agenix,
    }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.permittedInsecurePackages = [
            "python3.10-cryptography-40.0.1"
            "python3.10-requests-2.28.2"
            "python3.10-certifi-2022.9.24"
            "python2.7-certifi-2021.10.8"
            "python2.7-pyjwt-1.7.1"

          ];
        };
        agenix-pkg = agenix.packages.x86_64-linux.default;
      in
      {
        defaultPackage = pkgs.hello;
        devShell = pkgs.mkShell {
          packages = with pkgs; [
            nixops_unstable_full
            agenix-pkg
          ];
        };

      }
    )
    // {
      nixopsConfigurations.default = {
        inherit nixpkgs;
        network.storage.legacy = {
          databasefile = "~/.nixops/deployments.nixops";
        };

        k3s-master =
          { config, pkgs, ... }:
          {
            deployment.targetHost = "192.168.1.3";

            nix.settings.experimental-features = [
              "nix-command"
              "flakes"
            ];

            nixpkgs.config.allowUnfree = true;

            imports = [
              ./nixos/thinkserver/configuration.nix
              agenix.nixosModules.default
              ./apps/acme.nix
              ./apps/postgresql.nix
              ./apps/podman.nix

              ./apps/portal.nix
              ./apps/dl.nix
              ./apps/home-assistant.nix
              ./apps/wireguard.nix
              ./apps/romm.nix
              # ./apps/k3s.nix
            ];

            # Enable cron service
            services.cron = {
              enable = true;
            };

            services.timesyncd.enable = true;

            networking.firewall = {
              enable = true;
              allowedTCPPorts = [
                80
                443

                22 # ssh
                6443
                10250
                31248 # deluge
                9600 # assetto server
                8772 # assetto web
                8081 # assetto api
                51820

                5432
              ];

              allowedUDPPorts = [
                9600 # assetto server
                38899 # wiz lights broadcast address
                51820
              ];
            };

            networking.hostName = "k3s-master";

            environment.systemPackages = with pkgs; [
              vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
              nfs-utils
              git
              wget
              screen
            ];

            fileSystems."/mnt/k8s" = {
              device = "192.168.1.2:/volume1/k8s";
              fsType = "nfs";
            };

            services.nginx = {
              enable = true;
              recommendedProxySettings = true;
              # recommendedTlsSettings = true;
            };

          };
      };
    };
}
