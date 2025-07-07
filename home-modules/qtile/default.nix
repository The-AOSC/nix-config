{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    modules.qtile.enable = lib.mkEnableOption "qtile";
  };
  config = lib.mkIf config.modules.qtile.enable {
    home.packages = with pkgs; [
      (qtile-unwrapped.overrideAttrs (old: {
        patches =
          old.patches or []
          ++ [
            ./configure-numlock.patch # https://github.com/qtile/qtile/issues/4225
          ];
      }))
      #(pkgs.python3.withPackages (p: [qtile-unwrapped] ++ (with p; [
      #  sh
      #])))
    ];
    xdg.portal = {
      enable = true;
      config = {
        common = {
          default = [
            "wlr"
          ];
        };
      };
      extraPortals = with pkgs; [
        #xdg-desktop-portal-gtk
        #xdg-desktop-portal-kde
        xdg-desktop-portal-wlr
      ];
    };
    xdg.configFile = {
      "qtile" = {
        source = ./config;
        recursive = true;
      };
      "xkb" = {
        source = ./xkb-config;
        recursive = true;
      };
    };
  };
}
