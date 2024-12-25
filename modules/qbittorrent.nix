{lib, pkgs, pkgs-unstable, ...}: {
  modules.options.qbittorrent = {
    userPackages = [
      # 24/11.09: current version 4.6.4
      (lib.mkIf (lib.versionAtLeast pkgs.qbittorrent.version "5.0.1") pkgs.qbittorrent)
      #old
      /*
      (lib.mkIf (!(lib.versionAtLeast pkgs.qbittorrent.version "5.0.1")) (import <unstable> {
        system = pkgs.system;
      }).qbittorrent)
      */
      #new
      (lib.mkIf (!(lib.versionAtLeast pkgs.qbittorrent.version "5.0.1")) pkgs-unstable.qbittorrent)
    ];
    persist.user.config.directories = [
      ".config/qBittorrent"
    ];
    persist.user.data.directories = [
      ".local/share/qBittorrent"
    ];
  };
}
