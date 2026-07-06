{
  inputs,
  config,
  lib,
  ...
}: {
  den.hosts.x86_64-linux.evacuis.users.aosc = {};
  den.hosts.x86_64-linux.vestigia = {};
  flake.aspects = {aspects, ...}: {
    hosts = config.lib.aspects.make-namespace {
      perInstance = hostname: {
        includes = [
          aspects.base
        ];
        nixos.imports = [
          inputs.self.nixosModules.default
        ];
      };
    };
  };
  den.hosts.x86_64-linux.evacuis.instantiate = args:
    inputs.nixpkgs.lib.nixosSystem ({
        specialArgs = {inherit inputs;};
      }
      // args);
  den.hosts.x86_64-linux.vestigia.instantiate = args:
    inputs.nixpkgs.lib.nixosSystem ({
        specialArgs = {inherit inputs;};
      }
      // args);
  den.aspects.evacuis.nixos.imports = [
    (config.lib.aspects.aspects-lib.resolve "nixos" [] (inputs.self.aspects.hosts "evacuis"))
  ];
  den.aspects.vestigia.nixos.imports = [
    (config.lib.aspects.aspects-lib.resolve "nixos" [] (inputs.self.aspects.hosts "vestigia"))
  ];
}
