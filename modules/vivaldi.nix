{config, pkgs, ...}: {
  modules.options.vivaldi = {
    persist.user.data.directories = [
      ".config/vivaldi"
      ".local/lib/vivaldi"
    ];
    persist.user.data.files = [
      ".local/share/.vivaldi_reporting_data"
    ];
  };
  modules.modules.allow-unfree.allowUnfree = config.modules.lib.withModuleUsersConfig "vivaldi" [
    "vivaldi"
  ];
}
