# build with .#nixosConfigurations.nixos-installer.config.system.build.isoImage
{inputs, ...}: {
  flake.aspects = {aspects, ...}: {
    host._.nixos-installer = {
      includes = [aspects.base];
      nixos = {
        imports = [
          "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        ];
      };
    };
  };
}
