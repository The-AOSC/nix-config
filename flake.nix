{
  description = "NixOS configuration of The AOSC";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    impermanence.url = "github:nix-community/impermanence";
    # https://flakehub.com/flake/AshleyYakeley/NixVirt
    nixvirt.url = "https://flakehub.com/f/AshleyYakeley/NixVirt/*.tar.gz";
    nixvirt.inputs.nixpkgs.follows = "nixpkgs";
    nixvirt.inputs.nixpkgs-ovmf.follows = "nixpkgs";
    flake-programs-sqlite.url = "github:wamserma/flake-programs-sqlite";
    flake-programs-sqlite.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = inputs @ {
    flake-utils,
    home-manager,
    nixpkgs,
    self,
    ...
  }: {
    nixosModules = import ./nixos-modules;
    homeManagerModules = import ./home-modules;
    packages = flake-utils.lib.eachDefaultSystemMap (
      system: let
        pkgs = import nixpkgs {inherit system;};
      in {
        wtf = pkgs.callPackage ./packages/wtf.nix {};
      }
    );
    overlays = {
      wtf = final: prev: {
        wtf = final.callPackage ./packages/wtf.nix {};
      };
      always-redraw-progress-bar-on-log-output = final: prev: {
        nix = prev.nix.overrideAttrs (old: {
          patches =
            (old.patches or [])
            ++ [
              ./patches/nix/always-redraw-progress-bar-on-log-output.patch
            ];
        });
      };
    };
    nixosConfigurations = builtins.mapAttrs self.lib.mkNixosSystem (import ./hosts inputs);
    lib = {
      mkNixosSystem = host-name: host-config: (
        let
          specialArgs = {
            inherit inputs;
          };
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
                          imports = home-config.modules;
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
              ++ host-config.nixos-modules;
          }
      );
    };
    formatter = flake-utils.lib.eachDefaultSystemMap (
      system: nixpkgs.legacyPackages.${system}.alejandra
    );
  };
}
