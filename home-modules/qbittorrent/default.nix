{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    modules.qbittorrent.enable = lib.mkEnableOption "qbittorrent";
  };
  config = lib.mkIf config.modules.qbittorrent.enable {
    home.packages = [
      pkgs.qbittorrent
    ];
    home.persistence."/persist/home/aosc" = {
      directories = [
        ".config/qBittorrent"
        ".local/share/qBittorrent"
      ];
    };
  };
}
