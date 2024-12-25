{config, ...}: {
  modules.options.doas = {
    userPackages = [];
  };
  security.doas = config.modules.lib.withModuleSystemConfig "doas" {
    enable = true;
    extraRules = [
      {
        keepEnv = true;
        setEnv = [
          "-XDG_CACHE_HOME"
        ];
        groups = [
          "wheel"
        ];
      }
    ];
  };
  security.sudo.enable = config.modules.lib.withModuleSystemConfig "doas" false;
  users.users = config.modules.lib.withModuleUserConfig "doas" (user-name: {
    "${user-name}".extraGroups = [
      "wheel"
    ];
  });
}
