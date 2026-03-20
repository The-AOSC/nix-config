{
  flake.aspects = {
    host-vestigia.nixos = {
      imports = [
        ../../../nixos-configurations/vestigia/default.nix
      ];
    };
  };
}
