{
  inputs,
  lib,
  ...
}: {
  flake.nixosConfigurations = lib.mapAttrs (_: aspect:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        aspect.modules.nixos
        inputs.self.nixosModules.default
      ];
    })
  inputs.self.aspects.host._;
  flake.aspects = {aspects, ...}: {
    base.includes = [
      ({
        aspect-chain,
        class,
      }: {
        nixos.networking.hostName = lib.mkDefault (lib.elemAt aspect-chain 0).name;
      })
    ];
  };
}
