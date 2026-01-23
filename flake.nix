{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    agenix.url = "github:ryantm/agenix";

    nix-hytale-server = {
      url = "github:osipog/nix-hytale-server";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      agenix,
      nix-hytale-server,
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

        mkShellApp =
          body:
          let
            script = pkgs.writeShellScript "script.sh" body;
          in
          {
            type = "app";
            program = "${script}";
          };
      in
      {
        defaultPackage = pkgs.hello;
        devShell = pkgs.mkShell {
          packages = with pkgs; [
            nixops_unstable_full
            agenix-pkg
            mosquitto
            python313Packages.pywizlight
          ];
        };

        apps = {
          # Deploy the configuration to server
          deploy-as-root = mkShellApp ''
            ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake .#k3s-master --target-host root@k3s-master
          '';

        };
      }
    )
    // {
      nixosConfigurations = {
        k3s-master = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./nixos/thinkserver/configuration.nix
            ./nixos/k3s-master.nix
            agenix.nixosModules.default

            nix-hytale-server.nixosModules.hytale-server

            # system services
            ./apps/acme.nix
            ./apps/backup.nix
            ./apps/postgresql.nix
            ./apps/podman.nix
            ./apps/wireguard.nix

            # services
            ./apps/portal.nix
            ./apps/dl.nix
            ./apps/home-assistant
            ./apps/mqtt.nix
            ./apps/romm.nix
            ./apps/hytale.nix
            ./apps/jellyfin.nix
          ];
        };
      };
    };
}
