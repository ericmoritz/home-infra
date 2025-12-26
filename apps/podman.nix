{ pkgs, config, ... }:
{
  # Enable Podman in configuration.nix
  virtualisation.podman = {
    enable = true;
    # Create the default bridge network for podman
    # defaultNetwork.settings.dns_enabled = true;
  };
}
