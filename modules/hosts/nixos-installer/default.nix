# build with .#nixosConfigurations.nixos-installer.config.system.build.isoImage
{inputs, ...}: {
  flake.aspects = {aspects, ...}: {
    hosts._.nixos-installer = {
      includes = [
        (aspects.users "root")
        (aspects.users "root")._.remote
      ];
      nixos = {
        imports = [
          "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        ];
      };
    };
  };
}
