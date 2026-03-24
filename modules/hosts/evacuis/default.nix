{
  flake.aspects = {aspects, ...}: {
    host._.evacuis = {
      includes = [
        aspects.user._.root._.local
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
