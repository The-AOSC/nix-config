{
  inputs,
  den,
  lib,
  ...
}: {
  flake-file.inputs.disko.url = "github:nix-community/disko";
  den.schema.host = {
    options.disko.devices = lib.mkOption {
      type = lib.types.attrs;
      description = "Disko devices configuration";
      default = {};
    };
    includes = [
      den.aspects.disko
    ];
  };
  den.aspects.disko = {host, ...}: {
    nixos = lib.optionalAttrs (host.disko.devices != {}) {
      imports = [inputs.disko.nixosModules.disko];
      inherit (host) disko;
    };
  };
}
