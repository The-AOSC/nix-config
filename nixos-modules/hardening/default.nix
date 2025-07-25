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
    boot.kernel.sysctl."fs.binfmt_misc.status" =
      lib.mkIf (
        with config.boot.binfmt; ((emulatedSystems != []) || (registrations != {}))
      )
      1;
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
