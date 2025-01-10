{
  description = "NixOS configuration of The AOSC";
  inputs = {
    nixpkgs.follows = "nixpkgs-unstable";
    nixpkgs-24-05.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-24-11.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    #home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    impermanence.url = "github:nix-community/impermanence";
  };
  outputs = inputs@{
    home-manager,
    nixpkgs,
    nixpkgs-24-05,
    nixpkgs-24-11,
    nixpkgs-unstable,
    self,
    ...
  }: {
    nixosConfigurations = builtins.mapAttrs (host-name: host-config: (
      let
        system = host-config.system;
        pkgs-24-05 = import nixpkgs-24-05 {
          inherit system;
        };
        pkgs-24-11 = import nixpkgs-24-11 {
          inherit system;
        };
        pkgs-unstable = import nixpkgs-unstable {
          inherit system;
        };
        specialArgs = {
          inherit pkgs-24-05 pkgs-24-11 pkgs-unstable inputs;
        };
      in nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          {
            nix.settings.experimental-features = ["nix-command" "flakes"];
          }
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users = builtins.mapAttrs (user-name: home-config: ({osConfig, ...}: {
                imports = home-config.modules;
                home.homeDirectory = osConfig.users.users."${user-name}".home;
                home.username = user-name;
                programs.home-manager.enable = true;
              })) host-config.home;
              extraSpecialArgs = specialArgs;
            };
          }
        ] ++ host-config.nixos-modules;
      })) (import ./hosts inputs);
  };
}
