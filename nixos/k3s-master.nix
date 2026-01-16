{ pkgs, ... }:
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true;

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
      5432 # pgsql
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
    unrar
    unzip
    inetutils
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

}
