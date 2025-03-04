{pkgs, ...}: {
  home.packages = with pkgs; [
    liberation_ttf
    noto-fonts
    source-code-pro
    unifont
  ];
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [];
      sansSerif = [];
      serif = [];
    };
  };
}
