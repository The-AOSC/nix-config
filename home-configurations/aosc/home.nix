{...}: {
  profiles = {
    desktop = true;
  };
  modules.rldebugfs.enable = true;
  modules.swaylock.enable = true;
  modules.tor.enable = true;
  modules.tor-browser.enable = true;
  home.persistence."/persist" = {
    directories = [
      "dav"
      "dav-upload"
      "Desktop/colledge"
      "Desktop/Documents"
      "inst"
      "lisp"
      ".local/HyperSpec"
      "nix-config"
      "nixpkgs"
    ];
    files = [
      "TODO.norg"
    ];
  };
  home.persistence."/media" = {
    directories = [
      "Desktop/games"
      "Desktop/Movies"
      "Desktop/Music"
      "Desktop/Videos"
    ];
  };
  xdg.configFile."htop/htoprc".source = ./htoprc;
}
