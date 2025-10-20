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
          dmenu = "${pkgs.rofi}/bin/rofi -dmenu -p dunst";
          browser = "${pkgs.xdg-utils}/bin/xdg-open";
        };
      };
    };
  };
}
