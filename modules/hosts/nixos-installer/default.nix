{
  flake.aspects = {
    host-nixos-installer.nixos = {
      imports = [
        ../../../nixos-configurations/nixos-installer/default.nix
      ];
    };
  };
}
