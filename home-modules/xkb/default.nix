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
    programs.cava = {
      enable = true;
      settings = {
        general = {
          bar_width = 1;
          bar_spacing = 0;
        };
        smoothing.noise_reduction = 30;
      };
    };
  };
}
