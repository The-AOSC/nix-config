{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: {
  imports = let
    nix-mineral = lib.fix (self:
      (import "${inputs.nixpkgs.legacyPackages.x86_64-linux.applyPatches {
        name = "nix-mineral-patched";
        src = inputs.nix-mineral;
        patches = [
          ./override.patch
        ];
      }}/flake.nix").outputs (inputs.nix-mineral.inputs
        // {
          inherit self;
        }));
  in [
    nix-mineral.nixosModules.nix-mineral
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
          icmp.ignore-all = false;
        };
      };
    };
  };
}
