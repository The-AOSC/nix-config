{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    modules.libreoffice.enable = lib.mkEnableOption "libreoffice";
  };
  config = lib.mkIf config.modules.libreoffice.enable {
    home.packages = [
      pkgs.libreoffice
    ];
    home.persistence."/persist" = {
      directories = [
        ".config/libreoffice"
      ];
    };
  };
}
