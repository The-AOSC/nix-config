{config, pkgs, ...}: {
  modules.options.wireshark = {
    userPackages = [];
  };
  programs.wireshark = config.modules.lib.withModuleUsersConfig "wireshark" {
    enable = true;
    package = pkgs.wireshark;
  };
  users.users = config.modules.lib.withModuleUserConfig "wireshark" (user-name: {
    "${user-name}".extraGroups = [
      "wireshark"
    ];
  });
}
