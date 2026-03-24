{
  inputs,
  lib,
  ...
}: {
  flake.aspects = {aspects, ...}: {
    users = username: {
      includes = [
        ({
          aspect-chain,
          class,
        }: {
          includes = let
            aspect = aspects.user._.${username} or {};
            # user and homeManager aspects in user._.<username> should only be included for <username>
            filtered =
              if lib.elem class ["user" "homeManager"]
              then {}
              else aspect;
          in [filtered];
        })
        (aspects.users username)._.home-manager
        (aspects.users username)._.users-config
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
          (aspects.make-once {
            key = lib.mapAttrsToList (n: v: "${n}-${builtins.toString v}") __curPos;
            fromClasses = ["nixos"];
            fromAspect.nixos = {
              imports = [
                inputs.home-manager.nixosModules.home-manager
              ];
              home-manager = {
                extraSpecialArgs = {inherit inputs;};
                useGlobalPkgs = true;
                useUserPackages = true;
              };
            };
          })
          # home-manager config
          ({
            class,
            aspect-chain,
          }:
            aspects.make-forward {
              each = [
                # user specific config
                (aspects.user._.${username} or {})
                # system specific config
                (lib.head aspect-chain)
              ];
              fromClass = _: "homeManager";
              intoClass = _: "nixos";
              intoPath = _: ["home-manager" "users" username];
              fromAspect = aspect: aspect;
            })
        ];
        users-config.includes = [
          # users.users config
          ({
            class,
            aspect-chain,
          }:
            aspects.make-forward {
              each = [
                # user specific config
                (aspects.user._.${username} or {})
                # system specific config
                (lib.head aspect-chain)
              ];
              fromClass = _: "user";
              intoClass = _: "nixos";
              intoPath = _: ["users" "users" username];
              fromAspect = aspect: aspect;
            })
        ];
      };
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
