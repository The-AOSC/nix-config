{inputs, ...}: {
  imports = [
    ./configuration.nix
    ./disko.nix
    ./hardware-configuration.nix
    ./unfree.nix
    inputs.disko.nixosModules.disko
  ];
  nixpkgs.overlays = [
    inputs.self.overlays.fix-ssh-copy-id
    inputs.self.overlays.hypridle-wait-for-hyprlock-fadein
    inputs.self.overlays.wpctl-add-db-gain-change-support
    inputs.sops-nix.overlays.default
  ];
}
