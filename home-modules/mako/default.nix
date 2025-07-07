{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    modules.mako.enable = lib.mkEnableOption "mako";
  };
  config = lib.mkIf config.modules.mako.enable {
    home.packages = [
      pkgs.libnotify
    ];
    services.mako = {
      enable = true;
    };
  };
}
