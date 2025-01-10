{config, ...}: {
  modules.options.no-default-packages = {
    userPackages = [];
  };
  environment.defaultPackages = config.modules.lib.withModuleSystemConfig "no-default-packages" [];
}
