{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    modules.base.enable = lib.mkEnableOption "base";
  };
  config = lib.mkIf config.modules.base.enable {
    modules.ntp.enable = true;
    modules.persistence.enable = true;
    fileSystems."/etc/credentials" = {
      device = "/persist/etc/credentials";
      fsType = "none";
      neededForBoot = true;
      options = ["bind"];
    };
    networking = {
      networkmanager.enable = true;
      firewall = {
        enable = true;
        allowPing = true;
      };
    };
    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    programs.fish.enable = true;
    programs.nano.enable = false;
    programs.neovim.enable = true;
    environment.binsh = "${pkgs.dash}/bin/dash";
    systemd.tmpfiles.rules = [
      "D! /persist/tmp 1777 root root"
    ];
    nix.settings = {
      auto-optimise-store = true;
      build-dir = "/persist/tmp";
      keep-derivations = true;
      keep-failed = true;
      keep-going = true;
      keep-outputs = true;
    };
  };
}
