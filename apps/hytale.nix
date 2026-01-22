{ ... }:
{

  services.hytale-server = {
    enable = true;
    openFirewall = true;
    useRecommendedJvmOpts = true;
  };
}
