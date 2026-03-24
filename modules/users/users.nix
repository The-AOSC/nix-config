{lib, ...}: {
  flake.aspects = {aspects, ...}: {
    users = username: {
      includes = [
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
