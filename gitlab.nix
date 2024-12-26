{inputs, config, pkgs, ...}: {
  programs.ssh.knownHosts = {
    gitlab-ed25519 = {
      hostNames = [
        "ASUSLaptop"
        "localhost"
        "127.0.0.1"
        "::1"
      ];
      # "/persist/containers/gitlab/etc/ssh/ssh_host_ed25519_key.pub
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIELWyOhrbT/QTGoW1dQwKuAmjPxWzgQHCXCyXU1gDRYv";
    };
    gitlab-rsa = {
      hostNames = [
        "ASUSLaptop"
        "localhost"
        "127.0.0.1"
        "::1"
      ];
      # /persist/containers/gitlab/etc/ssh/ssh_host_rsa_key.pub
      publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCbLU2YnqE7OUKjjJZzSiAOLH3PALpeqW/RWd8VjpYzHz1VFL9Oqp7CuQveUkjk+8lEJ/Qw6a1C21su49ltbIQGTTLWNCaWMjwlKip7z61ZiVim3zSVNcn24IBpnfCpTV2J5zzhMlICA/dssBYcMZ/P2H80p20eiV/akSEcpemPVjRfHyT51pzqlazDadnBvRJV6LHbjpqDpjzz7pPWSdZ2dkM/fMbW0UnYCew1erjFarI3fMXc0farmXyBGa5V5frTDV+VYBgNVCmhD8nnSDk93XWF7+9cFXxzq+1Ea5TAo4pnOPRJFR0h1QZACaxMAe6PH7pdKy0n87sG8KZB6C5mtmMcggCGr1bTTKenpHPakH24JMovtT1HgVfqRdDujz8jo/u8N/UUNkG9cMlkpejAvJbATvBPGDKJQRU/d5NrKaDGRe/iPJXQeJxtz62FommyrmCzRdblk5FWL5CKaXuAnwdTehvmPm8IB31hviqFRZrxnIMAGXmTq/Ihix5qgL9yqyXW1hil6fWay+1pYYsPPEGnnreC3VK1mf2kign/52Pq3eFDoxZ/aHjLEwxHLxJVeIwoI+eiUEc3k25vlX8gN6JO2w7BwQb3wNPiq1AtNDH0MCxcfqmPMSAm3KrvYmU3XxKICpk4y9I13i8KILaLTqQgEuoYRYnlymmVIcarzQ==";
    };
  };
  users.users = let cfg = config.containers.gitlab.config; in {
    "${cfg.services.gitlab.user}" = {
      uid = assert cfg.users.users.gitlab.uid!=null; cfg.users.users.gitlab.uid;
      group = cfg.services.gitlab.group;
    };
    "postgres" = {
      uid = assert cfg.users.users.postgres.uid!=null; cfg.users.users.postgres.uid;
      group = "postgres";
    };
  };
  users.groups = let cfg = config.containers.gitlab.config; in {
    "${cfg.services.gitlab.group}".gid = assert cfg.users.groups.gitlab.gid!=null; cfg.users.groups.gitlab.gid;
    "postgres".gid = assert cfg.users.groups.postgres.gid!=null; cfg.users.groups.postgres.gid;
  };
  containers.gitlab = {
    autoStart = true;
    restartIfChanged = true;
    timeoutStartSec = "5min";
    forwardPorts = [
      {
        containerPort = 22;
        hostPort = 22;
        protocol = "tcp";
      }
      {
        containerPort = 80;
        hostPort = 80;
        protocol = "tcp";
      }
    ];
    bindMounts = {
      "/data" = {
        hostPath = "/persist/containers/gitlab";
        isReadOnly = false;
      };
    };
    ephemeral = true;
    specialArgs = {
      impermanence = inputs.impermanence.nixosModules.impermanence;
    };
    nixpkgs = inputs.nixpkgs;
    config = {impermanence, config, ...}: {
      imports = [
        impermanence
      ];
      services.gitlab = {
        enable = true;
        databasePasswordFile = "/etc/credentials/database";
        initialRootPasswordFile = "/etc/credentials/root";
        secrets = {
          secretFile = "/etc/credentials/secret";
          dbFile = "/etc/credentials/db";
          otpFile = "/etc/credentials/otp";
          jwsFile = "/etc/credentials/jws";  # openssl genrsa 4096
        };
        port = 80;
      };
      services.openssh.authorizedKeysFiles = [
        "${config.users.users."${config.services.gitlab.user}".home}/.ssh/authorized_keys"
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
      environment.persistence."/data" = {
        enable = true;
        hideMounts = true;
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
          "/etc/credentials"
          "/var/lib/nixos"
        ];
        files = [
          "/etc/ssh/ssh_host_ed25519_key"
          "/etc/ssh/ssh_host_ed25519_key.pub"
          "/etc/ssh/ssh_host_rsa_key"
          "/etc/ssh/ssh_host_rsa_key.pub"
        ];
      };
      users.users.root.password = "root";
      services.openssh = {
        enable = true;
        settings = {
          AllowUsers = [config.services.gitlab.user "root"];
          AllowGroups = [config.services.gitlab.group "root"];
          PubkeyAuthentication = true;
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
          UsePAM = true;
          PermitRootLogin = "no";
        };
      };
      system.stateVersion = "24.05";
    };
  };
}
