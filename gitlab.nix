{config, pkgs, ...}: {
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
    port = 80;
  };
  services.openssh.authorizedKeysFiles = [
    "${config.users.users."${config.services.gitlab.user}".home}/.ssh/authorized_keys"
  ];
  services.openssh.settings.AllowUsers = [
    config.services.gitlab.user
  ];
  services.openssh.settings.AllowGroups = [
    config.services.gitlab.group
  ];
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
        user = config.services.gitlab.user;
        group = config.services.gitlab.group;
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
        user = config.services.gitlab.user;
        group = config.services.gitlab.group;
        mode = "0700";
      }
    ];
  };
}
