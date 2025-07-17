{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    modules.gitlab.enable = lib.mkEnableOption "gitlab";
  };
  config = lib.mkIf config.modules.gitlab.enable {
    services.nginx = {
      enable = true;
      recommendedProxySettings = lib.mkDefault true;
      virtualHosts = {
        "gitlab" = {
          locations."/".proxyPass = "http://gitlab.containers";
        };
      };
    };
    networking.firewall = {
      allowedTCPPorts = [80];
    };
    users.users = let
      cfg = config.containers.gitlab.config;
    in {
      "${cfg.services.gitlab.user}" = {
        uid = assert cfg.users.users.gitlab.uid != null; cfg.users.users.gitlab.uid;
        group = cfg.services.gitlab.group;
      };
      "postgres" = {
        uid = assert cfg.users.users.postgres.uid != null; cfg.users.users.postgres.uid;
        group = "postgres";
      };
    };
    users.groups = let
      cfg = config.containers.gitlab.config;
    in {
      "${cfg.services.gitlab.group}".gid = assert cfg.users.groups.gitlab.gid != null; cfg.users.groups.gitlab.gid;
      "postgres".gid = assert cfg.users.groups.postgres.gid != null; cfg.users.groups.postgres.gid;
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
      ];
      bindMounts = {
        "/data" = {
          hostPath = "/persist/containers/gitlab";
          isReadOnly = false;
        };
      };
      ephemeral = true;
      specialArgs = {
        inherit inputs;
      };
      nixpkgs = inputs.nixpkgs;
      config = {
        inputs,
        config,
        lib,
        ...
      }: {
        imports = [
          inputs.impermanence.nixosModules.impermanence
          inputs.sops-nix.nixosModules.sops
        ];
        networking.firewall = {
          enable = true;
          allowedTCPPorts = [80];
        };
        services.gitlab = {
          enable = true;
          databasePasswordFile = config.sops.secrets.database-password.path;
          initialRootPasswordFile = config.sops.secrets.initial-root-password.path;
          secrets = {
            activeRecordDeterministicKeyFile = config.sops.secrets.active-record-deterministic-key.path;
            activeRecordPrimaryKeyFile = config.sops.secrets.active-record-primary-key.path;
            activeRecordSaltFile = config.sops.secrets.active-record-salt.path;
            dbFile = config.sops.secrets.db.path;
            jwsFile = config.sops.secrets.jws.path;
            otpFile = config.sops.secrets.otp.path;
            secretFile = config.sops.secrets.secret.path;
          };
          port = 80;
        };
        sops.secrets = lib.listToAttrs (lib.map (lib.flip lib.nameValuePair {
            sopsFile = ../../secrets/gitlab-secrets.yaml;
            owner = config.services.gitlab.user;
          }) [
            "active-record-deterministic-key"
            "active-record-primary-key"
            "active-record-salt"
            "database-password"
            "db"
            "initial-root-password"
            "jws"
            "otp"
            "secret"
          ]);
        services.postgresql.package = pkgs.postgresql_17;
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
            "/var/lib/nixos"
          ];
          files = [
            "/etc/ssh/ssh_host_ed25519_key"
            "/etc/ssh/ssh_host_ed25519_key.pub"
            "/etc/ssh/ssh_host_rsa_key"
            "/etc/ssh/ssh_host_rsa_key.pub"
          ];
        };
        services.openssh = {
          enable = true;
          openFirewall = true;
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
  };
}
