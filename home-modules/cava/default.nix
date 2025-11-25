{
  config,
  lib,
  ...
}: {
  options = {
    modules.cava.enable = lib.mkEnableOption "cava";
  };
  config = lib.mkIf config.modules.cava.enable {
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
