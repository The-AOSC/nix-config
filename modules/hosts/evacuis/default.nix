{inputs, ...}: {
  flake.aspects = {aspects, ...}: {
    host-evacuis = {
      includes = [
        aspects.base
        (aspects.users "aosc")
      ];
      nixos = {
        imports = [
          ./_hardware-configuration.nix
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.extraSpecialArgs = {inherit inputs;};
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
