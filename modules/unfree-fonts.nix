{config, pkgs, ...}: {
  modules.options.unfree-fonts = {
    userPackages = [];
  };
  fonts.packages = config.modules.lib.withModuleSystemConfig "unfree-fonts" [
    pkgs.corefonts
    pkgs.vistafonts
  ];
  modules.modules.allow-unfree.allowUnfree = config.modules.lib.withModuleSystemConfig "unfree-fonts" [
    "corefonts"
    "vista-fonts"
  ];
}
