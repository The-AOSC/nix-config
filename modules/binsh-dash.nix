{config, pkgs, ...}: {
  modules.options.binsh-dash = {
    userPackages = [];
  };
  environment.binsh = config.modules.lib.withModuleSystemConfig "binsh-dash" "${pkgs.dash}/bin/dash";
}
