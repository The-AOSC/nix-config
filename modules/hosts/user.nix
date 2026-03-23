{lib, ...}: {
  flake.aspects = {aspects, ...}: {
    users = username: {
      includes = [(aspects.user._.${username} or {})];
      nixos.users.users.${username}.isNormalUser = true;
      provides = {
        sops-password = sopsFile: {
          nixos = {config, ...}: {
            sops.secrets."${username}-password" = {
              inherit sopsFile;
              key = "hash";
              neededForUsers = true;
            };
            users.users.aosc.hashedPasswordFile = config.sops.secrets."${username}-password".path;
          };
        };
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
    };
  };
}
