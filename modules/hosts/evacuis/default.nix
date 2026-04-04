{
  flake.aspects = {aspects, ...}: {
    hosts._.evacuis = {
      includes = [
        (aspects.users "aosc")
        (aspects.users "root")
        (aspects.users "root")._.local
        aspects.zapret2
      ];
      nixos = {
        imports = [
          ./_hardware-configuration.nix
        ];
      };
    };
  };
}
