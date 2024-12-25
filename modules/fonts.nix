{config, pkgs, ...}: {
  modules.options.fonts = {
    userPackages = [];
  };
  fonts.packages = config.modules.lib.withModuleSystemConfig "fonts" [
    pkgs.liberation_ttf
    pkgs.source-code-pro
  ];
}
