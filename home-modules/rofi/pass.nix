{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf (config.modules.rofi.enable && config.modules.pass.enable) {
    home.packages = [pkgs.rofi-pass-wayland];
    xdg.configFile."rofi-pass/config".text = ''
      clip=clipboard
      default_do='copyMenu'
      USERNAME_field='login'
    '';
  };
}
