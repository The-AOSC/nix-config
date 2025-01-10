{config, options, lib, ...}: {
  modules.options.networking = {
    userPackages = [];
    persist.system.data.directories = [
      "/etc/NetworkManager/system-connections"
    ];
    extraOptions = {
      hostName = lib.mkOption {
        default = options.networking.hostName.default;
        type = options.networking.hostName.type;
        description = options.networking.hostName.description;
      };
    };
  };
  networking.networkmanager.enable = config.modules.lib.withModuleSystemConfig "networking" true;
  networking.firewall= config.modules.lib.withModuleSystemConfig "networking" {
    enable = true;
    allowPing = true;
  };
  networking.hostName = config.modules.lib.withModuleSystemConfig "networking" config.modules.modules.networking.hostName;
  users.users = config.modules.lib.withModuleUserConfig "networking" (user-name: {
    "${user-name}".extraGroups = [
      "networkmanager"
    ];
  });
}
