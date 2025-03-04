{pkgs, ...}: {
  home.packages = [
    pkgs.qbittorrent
  ];
  home.persistence."/persist/home/aosc" = {
    directories = [
      ".config/qBittorrent"
      ".local/share/qBittorrent"
    ];
  };
}
