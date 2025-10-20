{
  config,
  lib,
  ...
}: {
  options = {
    modules.swaylock.enable = lib.mkEnableOption "swaylock";
  };
  config = lib.mkIf config.modules.swaylock.enable {
    security.pam.services.swaylock = {};
  };
}
