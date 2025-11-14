{config, pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    ffmpeg
  ];

  services.home-assistant = {
    enable = true;

    openFirewall = true;

    extraComponents = [
      "default_config"
      "esphome"
      "met"
      "radio_browser"
      "ffmpeg"
    ];
    extraPackages = ps: with ps; [
      pywizlight
      google-nest-sdm
      grpcio
      securetar
      getmac
    ];

    config = {
      default_config = {};
      automation = [
        {
          alias = "Backup Home Assistant every night at 3 AM";
          trigger = {
            platform = "time";
            at = "03:00:00";
          };
          action = {
            alias = "Create backup now";
            service = "backup.create";
          };
        }
      ];
    };
  };

  services.cron.systemCronJobs = [
    # backup home-assistant hourly
    "00 * * * *      root    rsync -a --delete /var/lib/hass/ /mnt/k8s/hass/"
  ];

}
