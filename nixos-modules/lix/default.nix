{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    modules.lix.enable = lib.mkEnableOption "lix";
  };
  config = lib.mkIf config.modules.lix.enable {
    nixpkgs.overlays = lib.mkIf config.nix.monitored.enable [
      (final: prev: {
        nix-monitored = prev.nix-monitored.override {
          nix = final.lix;
        };
      })
    ];
    nix.package = lib.mkIf (!config.nix.monitored.enable) pkgs.lix;
  };
}
