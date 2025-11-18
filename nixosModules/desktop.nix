{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    modules.desktop.enable = lib.mkEnableOption "desktop";
  };
  config = lib.mkIf config.modules.desktop.enable {
    modules.base.enable = true;
    modules.enableNumlock.enable = true;
    modules.hyprland.enable = true;
    modules.kanata.enable = true;
    modules.kdeconnect.enable = true;
    modules.nix-index.enable = true;
    modules.nom.enable = true;
    modules.theme.enable = true;
    modules.u2f.enable = true;
    modules.wine.enable = true;
    modules.yubikey.enable = true;
    hardware.graphics.enable = true;
    users.users.aosc.hashedPasswordFile = config.sops.secrets.aosc-password.path;
    sops.secrets = {
      aosc-password = {
        key = "hash";
        sopsFile = ../secrets/aosc-password.yaml;
        neededForUsers = true;
      };
    };
    security.doas = {
      enable = true;
      extraRules = lib.mkMerge [
        (lib.mkBefore [
          {
            keepEnv = true;
            setEnv = [
              "-XDG_CACHE_HOME"
            ];
            groups = [
              "wheel"
            ];
          }
        ])
        [
          {
            keepEnv = true;
            setEnv = [
              "-XDG_CACHE_HOME"
              "SUDO_UID=$EUID"
            ];
            groups = [
              "wheel"
            ];
            cmd = "nixos-rebuild";
          }
        ]
      ];
    };
    programs.fuse.userAllowOther = true;
    services.logind.settings.Login = {
      HandleHibernateKey = "ignore";
      HandleLidSwitch = "ignore";
      HandlePowerKey = "ignore";
      HandleRebootKey = "ignore";
      HandleSuspendKey = "ignore";
    };
    services.pipewire = {
      enable = true;
      pulse.enable = true;
    };
    programs.wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };
    boot.kernel.sysctl."kernel.dmesg_restrict" = 0;
    documentation.nixos.includeAllModules = true;
    documentation.nixos.extraModuleSources = [inputs.self]; # remove references to configuration
  };
}
