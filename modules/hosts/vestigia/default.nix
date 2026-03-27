{
  flake.aspects = {aspects, ...}: {
    hosts._.vestigia = {
      includes = [
        (aspects.users "root")
        (aspects.users "root")._.local
        (aspects.users "root")._.remote
      ];
      nixos = {
        imports = [
          ./_hardware-configuration.nix
        ];
      };
    };
  };
}
