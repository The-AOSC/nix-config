{
  options,
  inputs,
  pkgs,
  lib,
  ...
}: {
  imports = builtins.attrValues (builtins.removeAttrs inputs.self.nixosModules ["default"]);
  config =
    {
      nixpkgs.overlays = [
        inputs.self.overlays.default
      ];
      environment.systemPackages = [pkgs.git];
      nix.channel.enable = false;
      nix.settings.experimental-features = ["nix-command" "flakes"];
    }
    // lib.optionalAttrs (options?home-manager) {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
      };
    };
}
