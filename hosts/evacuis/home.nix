{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.impermanence.homeManagerModules.impermanence
  ];
  modules.desktop.enable = true;
  modules.rldebugfs.enable = true;
  modules.swaylock.enable = true;
  modules.tor.enable = true;
  modules.tor-browser.enable = true;
  home.persistence."/persist/home/aosc" = {
    directories = [
      "Desktop/colledge"
      "Desktop/Documents"
      "inst"
      "lisp"
      ".local/chromium-extensions"
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
  home.persistence."/media/aosc" = {
    allowOther = true;
    directories = [
      {
        directory = "Desktop/games";
        method = "symlink";
      }
      "Desktop/.games"
      "Desktop/Movies"
      "Desktop/Music"
      "Desktop/Videos"
    ];
  };
  xdg.configFile."htop/htoprc".source = ./htoprc;
}
