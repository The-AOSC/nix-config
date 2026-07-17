{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    modules.nom.enable = lib.mkEnableOption "nom";
  };
  imports = [
    inputs.nix-monitored.nixosModules.default
  ];
  config = lib.mkIf config.modules.nom.enable {
    nixpkgs.overlays = [
      (final: prev: {
        comma = prev.comma.override {
          nix = config.nix.package;
        };
      })
      inputs.nom.overlays.default
    ];
    nix.monitored = {
      enable = true;
      notify = false;
    };
    programs.nh.enable = true;
    security.doas.extraRules = [
      {
        keepEnv = true;
        setEnv = [
          "-XDG_CACHE_HOME"
          "SUDO_UID=$EUID"
          "NH_BYPASS_ROOT_CHECK=true"
        ];
        groups = [
          "wheel"
        ];
        cmd = "nh";
      }
    ];
    environment.systemPackages = with pkgs; [
      nix-output-monitor
    ];
  };
}
