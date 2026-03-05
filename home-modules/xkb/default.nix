{
  config,
  lib,
  ...
}: {
  options = {
    modules.xkb.enable = lib.mkEnableOption "xkb";
  };
  config = lib.mkIf config.modules.xkb.enable {
    xdg.configFile."xkb".source = ./xkb;
  };
}
