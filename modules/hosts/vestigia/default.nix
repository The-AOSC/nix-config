{
  flake.aspects = {aspects, ...}: {
    host._.vestigia = {
      includes = [
        ((aspects.users "root")._.convert-user-aspects (user: [user._.local user._.remote]))
      ];
      nixos = {
        imports = [
          ./_hardware-configuration.nix
        ];
      };
    };
  };
}
