{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];
  options = {
    modules.base.enable = lib.mkEnableOption "base";
  };
  config = lib.mkIf config.modules.base.enable {
    modules.build-vm.enable = true;
    modules.hardening.enable = true;
    modules.ntp.enable = true;
    modules.persistence.enable = true;
    modules.sshd.enable = true;
    networking = {
      networkmanager.enable = true;
      firewall = {
        enable = true;
        allowPing = true;
      };
    };
    users.mutableUsers = false;
    users.users.root.hashedPasswordFile = config.sops.secrets.root-password.path;
    sops.secrets.root-password = {
      key = "hash";
      sopsFile = ../secrets/root-password.yaml;
      neededForUsers = true;
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
      "D! /persist/tmp 0755 root root"
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
