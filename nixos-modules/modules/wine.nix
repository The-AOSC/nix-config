{config, pkgs, ...}: {
  modules.options.wine = {
    userPackages = [
      #pkgs.wine-staging
      pkgs.wineWowPackages.staging
      #pkgs.wine-wayland
      pkgs.winetricks
    ];
  };
  hardware.graphics = config.modules.lib.withModuleUsersConfig "wine" {
    enable = true;
    enable32Bit = true;
  };
}
