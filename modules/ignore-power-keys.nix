{config, ...}: {
  modules.options.ignore-power-keys = {
    userPackages = [];
  };
  services.logind = config.modules.lib.withModuleSystemConfig "ignore-power-keys" {
    lidSwitch = "ignore";
    powerKey = "ignore";
    rebootKey = "ignore";
    suspendKey = "ignore";
    hibernateKey = "ignore";
  };
}
