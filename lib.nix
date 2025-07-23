inputs @ {
  home-manager,
  nixpkgs,
  self,
  ...
}: {
  import-all = dir: nixpkgs.lib.mapAttrs (path: type: (import (dir + "/${path}"))) (builtins.readDir dir);
  mkNixosSystem = host-name: host: (
    let
      specialArgs = {
        inherit inputs;
      };
      host-config = host inputs;
    in
      nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules =
          [
            ({pkgs, ...}: {
              environment.systemPackages = [pkgs.git];
              networking.hostName = host-name;
              nix.settings.experimental-features = ["nix-command" "flakes"];
            })
            {
              nixpkgs.overlays = host-config.overlays;
            }
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users =
                  builtins.mapAttrs (
                    user-name: home-config: ({osConfig, ...}: {
                      imports = home-config.modules ++ (nixpkgs.lib.attrValues self.homeManagerModules);
                      home.homeDirectory = osConfig.users.users."${user-name}".home;
                      home.stateVersion = osConfig.system.stateVersion;
                      home.username = user-name;
                      programs.home-manager.enable = true;
                    })
                  )
                  host-config.home;
                extraSpecialArgs = specialArgs;
              };
            }
          ]
          ++ (nixpkgs.lib.attrValues self.nixosModules)
          ++ host-config.nixos-modules;
      }
  );
}
