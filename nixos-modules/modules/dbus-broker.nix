{config, ...}: {
  modules.options.dbus-broker = {
    userPackages = [];
  };
  services.dbus.implementation = config.modules.lib.withModuleSystemConfig "dbus-broker" "broker";
}
