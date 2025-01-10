{config, ...}: {
  modules.options.systemd-boot = {
    userPackages = [];
  };
  boot.loader = config.modules.lib.withModuleSystemConfig "systemd-boot" {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
}
