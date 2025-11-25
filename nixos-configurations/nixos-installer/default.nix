# build with .#nixosConfigurations.nixos-installer.config.system.build.isoImage
{inputs, ...}: {
  imports = [
    ./configuration.nix
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
  ];
}
