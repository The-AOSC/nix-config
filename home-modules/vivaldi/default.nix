{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    modules.vivaldi.enable = lib.mkEnableOption "vivaldi";
  };
  config = lib.mkIf config.modules.vivaldi.enable {
    home.packages = [
      pkgs.vivaldi
    ];
    home.persistence."/persist" = {
      directories = [
        ".config/vivaldi"
        ".local/lib/vivaldi"
      ];
      files = [
        ".local/share/.vivaldi_reporting_data"
      ];
    };
  };
}
