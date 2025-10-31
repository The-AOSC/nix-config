{pkgs, ...}: {
  home.packages = with pkgs; [
    pkgs.corefonts
    pkgs.vista-fonts
  ];
}
