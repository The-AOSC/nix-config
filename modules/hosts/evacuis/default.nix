{
  flake.aspects = {aspects, ...}: {
    host._.evacuis = {
      includes = [
        (aspects.users "aosc")
        (aspects.users "root")
        (aspects.users "root")._.local
      ];
      nixos = {
        imports = [
          ./_hardware-configuration.nix
        ];
      };
    };
  };
}
