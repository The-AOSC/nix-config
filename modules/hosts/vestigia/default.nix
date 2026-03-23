{
  flake.aspects = {aspects, ...}: {
    host._.vestigia = {
      includes = [
        aspects.user._.root._.local
        aspects.user._.root._.remote
      ];
      nixos = {
        imports = [
          ./_hardware-configuration.nix
        ];
      };
    };
  };
}
