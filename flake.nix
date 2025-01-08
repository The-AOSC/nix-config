{
  description = "NixOS configuration of The AOSC";
  inputs = {
    nixpkgs.follows = "nixpkgs-24-05";
    nixpkgs-24-05.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-24-11.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    impermanence.url = "github:nix-community/impermanence";
  };
  outputs = inputs@{
    home-manager,
    nixpkgs,
    nixpkgs-24-05,
    nixpkgs-24-11,
    nixpkgs-unstable,
    impermanence,
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
          ({pkgs-24-05, pkgs-24-11, pkgs-unstable, ...}: {
            nixpkgs.overlays = [
              (final: prev: (with pkgs-24-05; {
              }) // (with pkgs-24-11; {
              }) // (with pkgs-unstable; {
              }))
            ];
          })
          home-manager.nixosModules.home-manager
          impermanence.nixosModules.impermanence
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users."${host-config.username}" = {
                imports = [
                  impermanence.homeManagerModules.impermanence
                ] ++ host-config.home-modules;
              };
              extraSpecialArgs = specialArgs;
            };
          }
        ] ++ host-config.nixos-modules;
      })) (import ./hosts inputs);
  };
}
