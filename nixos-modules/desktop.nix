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
    modules.command-not-found.enable = true;
    modules.enableNumlock.enable = true;
    modules.kanata.enable = true;
    modules.kdeconnect.enable = true;
    modules.wine.enable = true;
    nix.settings.allowed-users = ["@wheel"];
    hardware.graphics.enable = true;
    users.mutableUsers = false;
    users.users.root.hashedPasswordFile = "/etc/credentials/root.hashedpassword";
    security.doas = {
      enable = true;
      extraRules = [
        {
          keepEnv = true;
          setEnv = [
            "-XDG_CACHE_HOME"
          ];
          groups = [
            "wheel"
          ];
        }
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
      ];
    };
    programs.fuse.userAllowOther = true;
    services.logind = {
      hibernateKey = "ignore";
      lidSwitch = "ignore";
      powerKey = "ignore";
      rebootKey = "ignore";
      suspendKey = "ignore";
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
  };
}
