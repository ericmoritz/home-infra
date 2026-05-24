{ pkgs, ... }:
{
  # Only set this if using intel-vaapi-driver:
  nixpkgs.config.packageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
  };

  systemd.services.jellyfin.environment.LIBVA_DRIVER_NAME = "i965"; # or i965 for older GPUs
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "i965";
  };

  # From https://wiki.nixos.org/wiki/Jellyfin - VAAPI and Intel QSV
  hardware.graphics = {
    # hardware.opengl until NixOS 24.05
    enable = true;

    extraPackages = with pkgs; [
      intel-ocl # Generic OpenCL support

      # For older processors, use with LIBVA_DRIVER_NAME=i965:
      intel-vaapi-driver
      libva-vdpau-driver

    ];

  };

}
