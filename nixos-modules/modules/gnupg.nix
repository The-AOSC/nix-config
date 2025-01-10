{config, ...}: {
  modules.options.gnupg = {
    userPackages = [];
    persist.user.data.directories = [
      ".gnupg"
    ];
  };
  programs.gnupg.agent = config.modules.lib.withModuleUsersConfig "gnupg" {
    enable = true;
    enableSSHSupport = true;
  };
}
