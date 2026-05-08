{
  flake.aspects = {aspects, ...}: {
    hosts._.evacuis = {
      includes = [
        (aspects.glide "default" "/dev/input/event10")
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
