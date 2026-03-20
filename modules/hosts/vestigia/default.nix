{
  flake.aspects = {aspects, ...}: {
    host-vestigia = {
      includes = [aspects.base];
      nixos = {
        imports = [
          ../../../nixos-configurations/vestigia/default.nix
        ];
      };
    };
  };
}
