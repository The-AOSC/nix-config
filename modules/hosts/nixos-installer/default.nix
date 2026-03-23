# build with .#nixosConfigurations.nixos-installer.config.system.build.isoImage
{inputs, ...}: {
  flake.aspects = {aspects, ...}: {
    host._.nixos-installer = {
      nixos = {
        imports = [
          "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        ];
      };
    };
  };
}
