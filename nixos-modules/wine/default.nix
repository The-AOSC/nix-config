{
  config,
  lib,
  ...
}: {
  options = {
    modules.wine.enable = lib.mkEnableOption "wine";
  };
  config = lib.mkIf config.modules.wine.enable {
    programs.firejail.enable = true;
    hardware.graphics.enable32Bit = true;
  };
}
