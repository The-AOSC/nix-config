{inputs, ...}: {
  imports = [
    ./configuration.nix
    ./disko.nix
    ./hardware-configuration.nix
    ./screensaver.nix
  ];
  nixpkgs.overlays = [
    inputs.self.overlays.fix-ssh-copy-id
    inputs.sops-nix.overlays.default
  ];
}
