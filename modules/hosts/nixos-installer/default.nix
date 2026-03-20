{
  flake.aspects = {aspects, ...}: {
    host-nixos-installer = {
      includes = [aspects.base];
      nixos = {
        imports = [
          ../../../nixos-configurations/nixos-installer/default.nix
        ];
      };
    };
  };
}
