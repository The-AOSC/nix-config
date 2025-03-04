{pkgs, ...}: {
  home.persistence."/persist/home/aosc" = {
    directories = [
      "builder"
      "cyclone-linux"
      "Desktop/colledge"
      "Desktop/corrupted-games"
      "flakes"
      "inst"
      ".local/chromium-extensions"
      ".local/HyperSpec"
      "nix-config"
      "nixos-arm"
      "not-os"
      "rk3328-linux"
      "smb"
      "smbro"
    ];
  };
  home.persistence."/media/aosc" = {
    allowOther = true;
    directories = [
      "Desktop/games"
      "Desktop/Movies"
      "Desktop/Music"
      "Desktop/Videos"
    ];
  };
  xdg.configFile."htop/htoprc".source = ./htoprc;
  home.packages = with pkgs; [
    ncurses
  ];
}
