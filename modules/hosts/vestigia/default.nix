{
  flake.aspects = {aspects, ...}: {
    host._.vestigia = {
      nixos = {
        imports = [
          ./_hardware-configuration.nix
        ];
      };
    };
  };
}
