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
  };
  outputs = inputs@{
    home-manager,
    nixpkgs,
    self,
    ...
  }: {
    nixosConfigurations = builtins.mapAttrs (host-name: host-config: (
      let
        system = host-config.system;
        specialArgs = {
          inherit inputs;
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
