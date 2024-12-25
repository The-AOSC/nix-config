{config, pkgs, ...}: {
  modules.options.fish = {
    userPackages = [];
    persist.user.config.directories = [
      ".config/fish"
    ];
    persist.user.data.directories = [
      ".local/share/fish"
    ];
  };
  programs.fish.enable = config.modules.lib.withModuleUsersConfig "fish" true;
  users.users = config.modules.lib.withModuleUserConfig "fish" (user-name: {
    "${user-name}".shell = pkgs.fish;
  });
}
