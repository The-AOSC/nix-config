{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    modules.dunst.enable = lib.mkEnableOption "dunst";
  };
  config = lib.mkIf config.modules.dunst.enable {
    services.dunst = {
      enable = true;
      settings = {
        global = {
          dmenu = "${pkgs.wmenu}/bin/wmenu -p dunst";
          browser = "${pkgs.xdg-utils}/bin/xdg-open";
        };
      };
    };
  };
}
