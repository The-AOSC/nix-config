{
  config,
  lib,
  ...
}: {
  options = {
    modules.hyprland.enable = lib.mkEnableOption "hyprland";
  };
  config = lib.mkIf config.modules.hyprland.enable {
    security.pam.services.hyprlock = {};
    programs.uwsm = {
      enable = true;
      waylandCompositors = {};
    };
  };
}
