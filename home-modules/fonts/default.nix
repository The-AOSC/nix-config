{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    modules.fonts.enable = lib.mkEnableOption "fonts";
  };
  config = lib.mkIf config.modules.fonts.enable {
    home.packages = with pkgs;
      [
        liberation_ttf
        noto-fonts
        source-code-pro
        unifont
      ]
      ++ (builtins.filter lib.attrsets.isDerivation (builtins.attrValues nerd-fonts));
    fonts.fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [];
        sansSerif = [];
        serif = [];
      };
    };
  };
}
