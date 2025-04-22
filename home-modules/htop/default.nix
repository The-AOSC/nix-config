{
  pkgs,
  lib,
  ...
}: {
  home.packages = [
    pkgs.htop-vim
  ];
  xdg.configFile."htop/htoprc".source = lib.mkDefault ./htoprc;
}
