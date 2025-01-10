{config, ...}: {
  modules.options.git-daemon = {
    userPackages = [];
    persist.system.data.directories = [
      "/git"
    ];
  };
  services.gitDaemon = config.modules.lib.withModuleSystemConfig "git-daemon" {
    basePath = "/git/";
    enable = true;
    exportAll = true;
    options = "--enable=receive-pack";
  };
  users.users = config.modules.lib.withModuleUserConfig "git-daemon" (user-name: {
    "${user-name}".extraGroups = [
      "git"
    ];
  });
}
