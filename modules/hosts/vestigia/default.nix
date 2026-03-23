{
  flake.aspects = {aspects, ...}: {
    host-vestigia = {
      includes = [aspects.base];
      nixos = {
        imports = [
          ./_hardware-configuration.nix
          ../../../nixos-configurations/vestigia/default.nix
        ];
      };
    };
  };
}
