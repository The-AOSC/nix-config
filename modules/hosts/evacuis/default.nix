{
  flake.aspects = {aspects, ...}: {
    host._.evacuis = {
      includes = [
        ((aspects.users "root")._.convert-user-aspects (user: [user._.local]))
        (aspects.users "aosc")
      ];
      nixos = {
        imports = [
          ./_hardware-configuration.nix
        ];
      };
    };
  };
}
