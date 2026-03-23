{
  flake.aspects = {aspects, ...}: {
    host._.vestigia = {
      includes = [aspects.base];
      nixos = {
        imports = [
          ./_hardware-configuration.nix
        ];
      };
    };
  };
}
