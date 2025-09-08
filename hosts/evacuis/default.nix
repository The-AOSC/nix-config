inputs @ {...}: {
  overlays = [
    inputs.nur.overlays.default
    inputs.self.overlays.always-redraw-progress-bar-on-log-output
    inputs.self.overlays.catppuccin-userstyles
    inputs.self.overlays.christbashtree
    inputs.self.overlays.colorbindiff
    inputs.self.overlays.fix-feh
    inputs.self.overlays.stylus
    inputs.self.overlays.update-mindustry
    inputs.self.overlays.wtf
    inputs.sops-nix.overlays.default
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
