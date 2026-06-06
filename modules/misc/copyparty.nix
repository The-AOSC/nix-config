{inputs, ...}: {
  flake-file.inputs.copyparty.url = "github:9001/copyparty";
  flake.aspects.copyparty = {
    nixos = {
      config,
      pkgs,
      lib,
      ...
    }: let
      copyparty-hostname = "${config.networking.hostName}-copyparty";
      users = lib.attrNames (lib.filterAttrs (name: value: value.isNormalUser) config.users.users);
    in {
      imports = [inputs.copyparty.nixosModules.default];
      nixpkgs.overlays = [inputs.copyparty.overlays.default];
      environment.systemPackages = [pkgs.copyparty];
      services.copyparty = {
        enable = true;
        settings = {
          # network
          "i" = "unix:770:${config.services.copyparty.group}:/dev/shm/party.sock";
          "rproxy" = 1;
          # safety
          "no-html" = true;
          "no-logues" = true;
          "no-readme" = true;
          # ui
          "localtime" = true;
          "glang" = true;
          "nsort" = true;
          "ver" = true;
          "ui-norepl" = true;
          # admin panel
          "no-reload" = true;
        };
        accounts.admin.passwordFile = "/dev/null";
        globalExtraConfig = ''
          ipu: ::1/128=admin
          ipu: 127.0.0.0/8=admin
          ipr: ::1/128,127.0.0.0/8=admin
        '';
        volumes = lib.mkMerge (lib.map (user: {
            "/${user}" = {
              access."r." = "*";
              path = "/persist/home/${user}/dav";
              flags = {
                "assert_root" = true;
              };
            };
            "/${user}-upload" = {
              access."rwmd." = "*";
              path = "/persist/home/${user}/dav-upload";
              flags = {
                "chmod_d" = "775";
                "chmod_f" = "664";
                "assert_root" = true;
                "d2t" = true; # disable metadata collection
                "dthumb" = true; # disable thumbnails
              };
            };
          })
          users);
      };
      systemd.services.copyparty.serviceConfig.BindReadOnlyPaths = ["/persist/var/iso"];
      systemd.tmpfiles.settings."copyparty" = lib.mkMerge (lib.map (user: {
          # don't create directories, just give access to them
          "/persist/home/${user}/dav-upload" = lib.mkForce {
            a.argument = lib.concatStringsSep "," [
              # allow parent directory access to copyparty
              "u:${config.services.copyparty.user}:rwx"
              # give access to new directories created by user
              "d:u:${config.services.copyparty.user}:rwx"
              # give access to new directories created by copyparty
              "d:u:${user}:rwx"
            ];
          };
          "/persist/home/${user}/dav" = lib.mkForce {
            a.argument = lib.concatStringsSep "," [
              # allow parent directory access to copyparty
              "u:${config.services.copyparty.user}:r-x"
              # give access to new directories created by user
              "d:u:${config.services.copyparty.user}:r-x"
            ];
          };
          # need read/write access
          "/persist/home/${user}/dav/.hist".d = {
            user = ":${config.services.copyparty.user}";
            group = ":${config.services.copyparty.user}";
            mode = ":755";
          };
        })
        users);
      modules.netConfig.extraHostnames = [copyparty-hostname];
      networking.hosts = {
        "127.0.0.3" = [copyparty-hostname];
        "::1" = [copyparty-hostname];
      };
      users.users.nginx.extraGroups = [config.services.copyparty.group];
      services.nginx = {
        enable = true;
        recommendedProxySettings = lib.mkDefault true;
        virtualHosts = let
          virtHost = {
            locations."/".proxyPass = "http://unix:/dev/shm/party.sock";
            extraConfig = ''
              client_max_body_size 1G;
            '';
          };
        in {
          "${copyparty-hostname}" = virtHost // {default = true;};
          "${copyparty-hostname}.local" = virtHost;
        };
      };
    };
  };
}
