{
  inputs,
  lib,
  ...
}: {
  flake.nixosConfigurations = lib.mapAttrs' (
    module-name: module: let
      name = lib.removePrefix "host-" module-name;
      system = inputs.nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          module
          inputs.self.nixosModules.default
        ];
      };
    in
      lib.nameValuePair name system
  ) (lib.filterAttrs (name: _: lib.hasPrefix "host-" name) inputs.self.modules.nixos);
  flake.aspects = {aspects, ...}: {
    base.includes = [
      ({
        aspect-chain,
        class,
      }: let
        aspect-names = lib.map (aspect: aspect.name) aspect-chain;
        host-aspect-name = lib.findFirst (lib.hasPrefix "host-") "host-nixos" aspect-names;
        hostname = lib.removePrefix "host-" host-aspect-name;
      in {
        nixos = {
          networking.hostName = lib.mkDefault hostname;
        };
      })
    ];
  };
}
