{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf (config.modules.rofi.enable && config.modules.pass.enable) {
    programs.rofi.pass = {
      enable = true;
      package = pkgs.rofi-pass-wayland;
      extraConfig = ''
        clip=clipboard
        default_do='copyMenu'
        USERNAME_field='login'
      '';
    };
  };
}
