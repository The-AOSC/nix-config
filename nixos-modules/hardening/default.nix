{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    inputs.nix-mineral.nixosModules.nix-mineral
  ];
  options = {
    modules.hardening.enable = lib.mkEnableOption "hardening";
  };
  config = lib.mkIf config.modules.hardening.enable {
    nix-mineral = {
      enable = true;
      filesystems.enable = false;
      settings = {
        debug = {
          dmesg-restrict = false;
          quiet-boot = false;
        };
        etc = {
          generic-machine-id = false;
          kicksecure-gitconfig = false;
          kicksecure-issue = false;
          no-root-securetty = false; # allow local root login
        };
        kernel = {
          amd-iommu-force-isolation = false;
          lockdown = false; # hibernation
          binfmt-misc = lib.mkIf (with config.boot.binfmt; ((emulatedSystems != []) || (registrations != {}))) true;
        };
        network = {
          # allow pings via ff02::1
          icmp.cast = true;
          icmp.ignore-all = false;
        };
      };
    };
  };
}
