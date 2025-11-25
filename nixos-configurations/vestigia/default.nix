{inputs, ...}: {
  imports = [
    ./configuration.nix
    ./disko.nix
    ./hardware-configuration.nix
    inputs.disko.nixosModules.disko
  ];
  nixpkgs.overlays = [
    inputs.self.overlays.fix-ssh-copy-id
    inputs.sops-nix.overlays.default
  ];
}
