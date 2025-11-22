{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./nix-mineral.nix
  ];
  options = {
    modules.hardening.enable = lib.mkEnableOption "hardening";
  };
  config = lib.mkIf config.modules.hardening.enable {
    nix-mineral.enable = true;
    fileSystems = {
      "/etc".enable = false;
      "/home".enable = false;
      "/root".enable = false;
      "/srv".enable = false;
      "/tmp".enable = false;
      "/var".enable = false;
    };
    boot.kernel.sysctl = {
      "net.ipv4.icmp_echo_ignore_all" = false;
      "net.ipv6.icmp.echo_ignore_all" = false;
      "fs.binfmt_misc.status" =
        lib.mkIf
        (with config.boot.binfmt; ((emulatedSystems != []) || (registrations != {})))
        true;
    };
    nix-mineral.overrides = {
      compatibility = {
        allow-busmaster-bit = true; # check if needed, probably not
        no-lockdown = true; # hibernation
      };
      desktop = {
        allow-multilib = true;
        hideproc-off = true;
        skip-restrict-home-permission = true;
      };
      performance = {
      };
      security = {
        disable-amd-iommu-forced-isolation = true;
        disable-bluetooth-kmodules = true;
        disable-intelme-kmodules = true;
      };
      software-choice = {
      };
    };
  };
}
