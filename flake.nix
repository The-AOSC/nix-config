{
  description = "NixOS configuration of The AOSC";
  inputs = {
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    impermanence.url = "github:nix-community/impermanence";
  };
  outputs = inputs@{
    home-manager,
    nixpkgs,
    nixpkgs-unstable,
    impermanence,
    self,
    ...
  }: let
    system = "x86_64-linux";
    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
    };
  in {
    nixosConfigurations = builtins.mapAttrs (host-name: host-config: (
      let
        system = host-config.system;
        pkgs-unstable = import nixpkgs-unstable {
          inherit system;
        };
        specialArgs = {
          inherit pkgs-unstable inputs;
        };
      in nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          home-manager.nixosModules.home-manager
          impermanence.nixosModules.impermanence
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users."${host-config.username}" = {
                imports = host-config.home-modules;
              };
              extraSpecialArgs = specialArgs;
            };
          }
        ] ++ host-config.nixos-modules;
      })) (import ./hosts inputs);
  };
}
