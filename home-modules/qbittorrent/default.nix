{pkgs, ...}: {
  home.packages = [
    pkgs.qbittorrent
  ];
  home.persistence."/persist/storage/home/vladimir" = {
    directories = [
      ".config/qBittorrent"
      ".local/share/qBittorrent"
    ];
  };
}
