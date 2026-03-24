{lib, ...}: {
  flake.aspects = {aspects, ...}: {
    users = username: {
      includes = [
        aspects.shared-home-manager
        (aspects.user._.${username} or {})
        (aspects.users username)._.home-manager
      ];
      nixos.users.users.${username}.isNormalUser = lib.mkIf (username != "root") true;
      provides = {
        sops-password = sopsFile: {
          nixos = {config, ...}: {
            sops.secrets."${username}-password" = {
              inherit sopsFile;
              key = "hash";
              neededForUsers = true;
            };
            users.users.${username}.hashedPasswordFile = config.sops.secrets."${username}-password".path;
          };
        };
        home-manager.includes = [
          # user specific config
          (aspects.make-forward {
            each = [username];
            fromClass = _: "homeManager";
            intoClass = _: "nixos";
            intoPath = user: ["home-manager" "users" user];
            fromAspect = _: aspects.user._.${username} or {};
          })
        ];
      };
    };
    shared-home-manager = aspects.make-once {
      # system specific config
      key = lib.mapAttrsToList (n: v: "${n}-${builtins.toString v}") __curPos;
      fromClasses = ["nixos"];
      fromAspect.includes = [
        {
          nixos = {config, ...}: {
            options.home-manager._sharedModule = lib.mkOption {
              type = lib.types.raw;
              internal = true;
            };
            config.home-manager.sharedModules = [config.home-manager._sharedModule];
          };
        }
        ({
          class,
          aspect-chain,
        }:
          aspects.make-forward {
            each = [null];
            fromClass = _: "homeManager";
            intoClass = _: "nixos";
            intoPath = _: ["home-manager" "_sharedModule"];
            fromAspect = _: lib.head aspect-chain;
          })
      ];
    };
    user.provides = {
      aosc = {
        includes = [
          ((aspects.users "aosc")._.sops-password ../../secrets/aosc-password.yaml)
        ];
        nixos = {pkgs, ...}: {
          users.users.aosc = {
            openssh.authorizedKeys.keyFiles = [
              ../../credentials/aosc.authorized_keys
            ];
            shell = pkgs.fish;
          };
        };
      };
      root = {
        provides.local.includes = [((aspects.users "root")._.sops-password ../../secrets/root-password.yaml)];
        provides.remote.nixos.users.users.root.openssh.authorizedKeys.keyFiles = [
          ../../credentials/aosc.authorized_keys
        ];
      };
    };
  };
}
