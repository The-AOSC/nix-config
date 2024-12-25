{config, ...}: {
  modules.options.tmux = {
    userPackages = [];
  };
  programs.tmux = config.modules.lib.withModuleSystemConfig "tmux" {
    enable = true;
    keyMode = "vi";
    clock24 = true;
    newSession = true;
  };
}
