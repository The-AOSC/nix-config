{options, config, lib, pkgs, ...}: {
  modules.options.sway = {
    userPackages = [];
  };
  programs.sway.enable = config.modules.lib.withModuleUsersConfig "sway" true;
  programs.sway.extraPackages = config.modules.lib.withModuleUsersConfig "sway" ((
    lib.lists.remove pkgs.swaylock (
      lib.lists.remove pkgs.foot options.programs.sway.extraPackages.default
      )) ++ [(pkgs.swaylock.overrideAttrs (old: {
        patches = (old.patches or []) ++ [
          ../patches/swaylock/swaylock-1.8.0-revert-drop-support-for-layer-shell.patch
        ];
      }))]);
  services.libinput.enable = config.modules.lib.withModuleUsersConfig "sway" true;
  hardware.graphics.enable = config.modules.lib.withModuleUsersConfig "sway" true;
  # TODO: is this necessary?
  users.users = config.modules.lib.withModuleUserConfig "sway" (user-name: {
    "${user-name}".extraGroups = [
      "video"
    ];
  });
}
