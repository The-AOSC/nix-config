{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.disko
    inputs.sops-nix.nixosModules.sops
  ];
  options = {
    profiles.base = lib.mkEnableOption "base";
  };
  config = lib.mkIf config.profiles.base {
    modules.build-vm.enable = true;
    modules.hardening.enable = true;
    modules.netConfig.enable = true;
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
    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    programs.fish.enable = true;
    programs.nano.enable = false;
    programs.neovim.enable = true;
    environment.binsh = "${pkgs.dash}/bin/dash";
    environment.systemPackages = with pkgs; [
      inetutils
      (lib.hiPrio unixtools.hostname)
      (lib.hiPrio unixtools.ping)
    ];
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
