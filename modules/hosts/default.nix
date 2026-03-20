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
          {
            networking.hostName = name;
          }
        ];
      };
    in
      lib.nameValuePair name system
  ) (lib.filterAttrs (name: _: lib.hasPrefix "host-" name) inputs.self.modules.nixos);
}
