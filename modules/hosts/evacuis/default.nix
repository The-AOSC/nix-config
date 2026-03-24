{inputs, ...}: {
  flake.aspects = {aspects, ...}: {
    host._.evacuis = {
      includes = [
        aspects.user._.root._.local
        (aspects.users "aosc")
      ];
      nixos = {
        imports = [
          ./_hardware-configuration.nix
          {
            home-manager.users.aosc.imports = [
              ../../../home-configurations/aosc/default.nix
              inputs.self.homeModules.default
            ];
          }
        ];
      };
    };
  };
}
