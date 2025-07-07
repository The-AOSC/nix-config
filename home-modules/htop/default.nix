{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    modules.htop.enable = lib.mkEnableOption "htop";
  };
  config = lib.mkIf config.modules.htop.enable {
    home.packages = [
      pkgs.htop-vim
    ];
    xdg.configFile = {
      "htop/htoprc".source = lib.mkDefault ./htoprc;
    };
  };
}
