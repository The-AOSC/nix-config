{pkgs, ...}: {
  home.packages = [
    pkgs.htop
  ];
  xdg.configFile."htop/htoprc".source = ./htoprc;
}
