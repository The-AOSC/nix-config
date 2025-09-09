{...}: {
  modules.desktop.enable = true;
  modules.rldebugfs.enable = true;
  modules.swaylock.enable = true;
  modules.tor.enable = true;
  modules.tor-browser.enable = true;
  wayland.windowManager.hyprland.settings.monitorv2 = [
    {
      output = "eDP-1";
      mode = "1920x1080@60";
    }
    {
      output = "";
      mode = "highres";
      position = "auto";
      scale = 1;
    }
  ];
  home.persistence."/persist" = {
    directories = [
      "Desktop/colledge"
      "Desktop/Documents"
      "inst"
      "lisp"
      ".local/HyperSpec"
      "nix-config"
      "nixpkgs"
      "smb"
      "smbro"
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
