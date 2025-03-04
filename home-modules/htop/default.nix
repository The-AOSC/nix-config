{pkgs, lib, ...}: {
  home.packages = [
    pkgs.htop
  ];
  xdg.configFile."htop/htoprc".source = lib.mkDefault ./htoprc;
}
