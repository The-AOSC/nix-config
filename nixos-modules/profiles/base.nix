{
  config,
  lib,
  ...
}: {
  options = {
    profiles.base = lib.mkEnableOption "base";
  };
  config = lib.mkIf config.profiles.base {
    modules.build-vm.enable = true;
    modules.hardening.enable = true;
    modules.lix.enable = true;
    modules.netConfig.enable = true;
    modules.ntp.enable = true;
    modules.sshd.enable = true;
  };
}
