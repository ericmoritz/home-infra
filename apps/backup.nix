{ pkgs, config, ... }:
{
  age.secrets.restic-password.file = ../secrets/restic-password.age;

  services.restic.backups."system" = {
    # make sure you ssh-copy-id to this server so that it can be accessible
    repository = "sftp://u387620-sub6@u387620-sub6.your-storagebox.de:23/restic";
    initialize = true;

    passwordFile = config.age.secrets.restic-password.path;

    extraBackupArgs = [
      "--verbose=2"
      "--exclude-caches"
    ];

    paths = [
      "/var/lib"
    ];
  };
}
