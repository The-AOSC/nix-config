{
  inputs,
  lib,
  ...
}: {
  flake.nixosConfigurations = lib.mapAttrs (hostname: aspect:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        aspect.modules.nixos
        inputs.self.aspects.base.modules.nixos
        inputs.self.nixosModules.default
        {
          networking.hostName = hostname;
        }
      ];
    })
  inputs.self.aspects.host._;
}
