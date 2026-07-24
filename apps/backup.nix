{ pkgs, config, ... }:
{
  age.secrets.restic-password.file = ../secrets/restic-password.age;
  age.secrets.restic-s3-env.file = ../secrets/restic-s3-env.age;

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

  services.restic.backups."system-s3" = {
    # make sure you ssh-copy-id to this server so that it can be accessible
    repository = "s3:s3.us-east-1.amazonaws.com/apps-home-restic-354639503391-us-east-1-an/restic";
    initialize = true;

    environmentFile = config.age.secrets.restic-s3-env.path;
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
