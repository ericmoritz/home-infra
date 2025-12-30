{ pkgs, config, ... }:
{
  # This file has the password hashes for the users
  age.secrets.pgsql-init-sql = {
    file = ../secrets/pgsql-init.sql.age;
    owner = "postgres";
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_17;
    enableTCPIP = true;

    authentication = pkgs.lib.mkForce ''
      #type database  DBuser  auth-method
      local all       all     trust
      host  sameuser  all     all scram-sha-256
    '';

    initialScript = config.age.secrets.pgsql-init-sql.path;

    ensureDatabases = [ "romm" ];
    ensureUsers = [
      {
        name = "romm";
        ensureDBOwnership = true;
        ensureClauses = {
          login = true;
        };
      }
    ];
  };

  services.postgresqlBackup = {
    enable = true;
    databases = [ "romm" ];
  };
}
