{inputs, ...}: {
  flake.aspects.host-vestigia.nixos.nixpkgs.overlays = [
    inputs.self.overlays.fix-ssh-copy-id
    inputs.sops-nix.overlays.default
  ];
}
