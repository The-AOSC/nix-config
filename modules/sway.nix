{options, config, lib, pkgs, ...}: {
  modules.options.sway = {
    userPackages = [];
  };
  programs.sway.enable = config.modules.lib.withModuleUsersConfig "sway" true;
  programs.sway.extraPackages = config.modules.lib.withModuleUsersConfig "sway" (lib.lists.remove pkgs.foot options.programs.sway.extraPackages.default);
  services.libinput.enable = config.modules.lib.withModuleUsersConfig "sway" true;
  hardware.opengl = config.modules.lib.withModuleUsersConfig "sway" {
    enable = true;
    driSupport = true;  # no longer has any effect
  };
  # TODO: is this necessary?
  users.users = config.modules.lib.withModuleUserConfig "sway" (user-name: {
    "${user-name}".extraGroups = [
      "video"
    ];
  });
}
