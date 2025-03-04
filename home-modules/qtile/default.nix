{pkgs, ...}: {
  home.packages = with pkgs; [
    qtile-unwrapped
    #(pkgs.python3.withPackages (p: [qtile-unwrapped] ++ (with p; [
    #  sh
    #])))
  ];
  xdg.portal = {
    enable = true;
    config = {
      common = {
        default = [
          "wlr"
        ];
      };
    };
    extraPortals = with pkgs; [
      #xdg-desktop-portal-gtk
      #xdg-desktop-portal-kde
      xdg-desktop-portal-wlr
    ];
  };
  xdg.configFile."qtile" = {
    source = ./config;
    recursive = true;
  };
  xdg.configFile."xkb" = {
    source = ./xkb-config;
    recursive = true;
  };
}
