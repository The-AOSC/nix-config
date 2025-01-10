{config, pkgs, ...}: let with-config = config.modules.lib.withModuleUsersConfig "qtile";
in {
  modules.options.qtile = {
    userPackages = [];
    persist.user.config.directories = [
      ".config/qtile"
    ];
  };
  services.xserver.windowManager.qtile = with-config {
    enable = true;
    #backend = "wayland";  # no longer has any effect
    extraPackages = python3Packages: with python3Packages; [
      sh
    ];
  };
  services.libinput.enable = with-config true;
  hardware.graphics.enable = with-config true;
  users.users = config.modules.lib.withModuleUserConfig "qtile" (user-name: {
    "${user-name}".extraGroups = [
      # TODO: is this necessary?
      "video"
    ];
  });
  xdg.portal = with-config {
    enable = true;
    extraPortals = with pkgs; [
      #xdg-desktop-portal-kde
      #xdg-desktop-portal-gtk
    ];
    wlr = {
      enable = true;
    };
  };
}
