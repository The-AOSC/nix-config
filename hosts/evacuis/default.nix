inputs @ {...}: {
  overlays = [
    inputs.self.overlays.always-redraw-progress-bar-on-log-output
    inputs.self.overlays.wtf
  ];
  nixos-modules = [
    ./configuration.nix
    ./hardware-configuration.nix
    ./unfree.nix
  ];
  home = {
    "aosc" = {
      modules = [
        ./home.nix
        ./unfree-fonts.nix
      ];
    };
  };
}
