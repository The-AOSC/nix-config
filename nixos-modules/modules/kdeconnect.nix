{config, pkgs, ...}: {
  modules.options.kdeconnect = {
    userPackages = [
      pkgs.plasma5Packages.kdeconnect-kde
    ];
    persist.user.data.directories = [
      ".config/kdeconnect"
    ];
  };
  networking.firewall = config.modules.lib.withModuleUsersConfig "kdeconnect" {
    allowedTCPPortRanges = [{
      from = 1714;
      to = 1764;
    }];
    allowedUDPPortRanges = [{
      from = 1714;
      to = 1764;
    }];
  };
}
