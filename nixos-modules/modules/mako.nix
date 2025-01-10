{config, pkgs, ...}: {
  modules.options.mako = {
    userPackages = [
      pkgs.libnotify
      pkgs.mako
    ];
  };
  services.dbus.packages = config.modules.lib.withModuleUsersConfig "mako" [
    pkgs.mako
  ];
}
