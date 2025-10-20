{
  config,
  lib,
  ...
}: {
  options = {
    modules.build-vm.enable = lib.mkEnableOption "build-vm";
  };
  config = lib.mkIf config.modules.build-vm.enable {
    virtualisation = {
      vmVariant = {
        modules.u2f.enable = lib.mkVMOverride false;
        security.pam.services = let
          serviceConfig = {
            rules.auth.permit = {
              enable = true;
              control = "sufficient";
              modulePath = "${config.security.pam.package}/lib/security/pam_permit.so";
              order = -1000;
            };
          };
        in {
          login = serviceConfig;
          doas = serviceConfig;
        };
        virtualisation = {
          cores = 2;
          memorySize = 2048;
          diskImage = null;
          qemu.options = [
            "-display gtk,zoom-to-fit=on"
          ];
        };
      };
    };
  };
}
