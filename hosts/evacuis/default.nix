inputs @ {...}: {
  overlays = [
    inputs.nix-gaming.overlays.default
    inputs.nur.overlays.default
    inputs.self.overlays.catppuccin-userstyles
    inputs.self.overlays.christbashtree
    inputs.self.overlays.colorbindiff
    inputs.self.overlays.fish-downgrade
    inputs.self.overlays.fix-ssh-copy-id
    inputs.self.overlays.hypridle-wait-for-hyprlock-fadein
    inputs.self.overlays.multi-dimensional-workspaces
    inputs.self.overlays.nix-flake-add-roots
    inputs.self.overlays.stylus
    inputs.self.overlays.update-mindustry
    inputs.self.overlays.wine-fixes
    inputs.self.overlays.wpctl-add-db-gain-change-support
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
