{pkgs, ...}: {
  services.gitlab = {
    enable = true;
    databasePasswordFile = "/etc/credentials/gitlab/database";
    initialRootPasswordFile = "/etc/credentials/gitlab/root";
    secrets = {
      secretFile = "/etc/credentials/gitlab/secret";
      dbFile = "/etc/credentials/gitlab/db";
      otpFile = "/etc/credentials/gitlab/otp";
      jwsFile = "/etc/credentials/gitlab/jws";  # openssl genrsa 4096
    };
  };
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts = {
      localhost = {
        locations."/".proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
      };
    };
  };
  systemd.services.gitlab-backup.environment.BACKUP = "dump";
  environment.persistence."/persist/storage" = {
    directories = [
      {
        directory = "/var/gitlab/state";
        user = "gitlab";
        group = "gitlab";
        mode = "0750";
      }
      {
        directory = "/var/lib/postgresql";
        user = "postgres";
        group = "postgres";
        mode = "0750";
      }
      {
        directory = "/var/lib/redis-gitlab";
        user = "gitlab";
        group = "gitlab";
        mode = "0700";
      }
    ];
  };
}
