{
  inputs,
  config,
  lib,
  ...
}: {
  flake.aspects = {aspects, ...}: {
    hosts = config.lib.aspects.make-namespace {
      perInstance = hostname: {
        includes = [
          aspects.base
        ];
        nixos.imports = [
          inputs.self.nixosModules.default
        ];
        nixos.networking.hostName = hostname;
      };
    };
  };
  flake.nixosConfigurations = lib.mapAttrs (hostname: aspect:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        (config.lib.aspects.aspects-lib.resolve "nixos" [] (inputs.self.aspects.hosts hostname))
      ];
    })
  inputs.self.aspects.hosts._;
}
