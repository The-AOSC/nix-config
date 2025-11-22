inputs @ {...}: {
  overlays = [
    inputs.self.overlays.fix-ssh-copy-id
    inputs.sops-nix.overlays.default
  ];
  nixos-modules = [
    ./configuration.nix
    ./disko.nix
    ./hardware-configuration.nix
    inputs.disko.nixosModules.disko
  ];
  home = {};
}
