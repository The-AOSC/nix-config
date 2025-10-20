{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    modules.mindustry.enable = lib.mkEnableOption "mindustry";
  };
  config = lib.mkIf config.modules.mindustry.enable {
    home.packages = [
      pkgs.mindustry-wayland
    ];
    home.persistence."/persist" = {
      directories = [
        ".local/share/Mindustry"
      ];
    };
  };
}
