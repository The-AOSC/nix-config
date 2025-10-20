{
  config,
  lib,
  ...
}: {
  options = {
    modules.zathura.enable = lib.mkEnableOption "zathura";
  };
  config = lib.mkIf config.modules.zathura.enable {
    programs.zathura = {
      enable = true;
    };
  };
}
