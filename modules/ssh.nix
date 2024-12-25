{config, options, lib, ...}: {
  modules.options.ssh = {
    extraOptions = {
      knownHosts = lib.mkOption {
        default = options.programs.ssh.knownHosts.default;
        type = options.programs.ssh.knownHosts.type;
        description = options.programs.ssh.knownHosts.description;
      };
    };
  };
  programs.ssh = {
    knownHosts = config.modules.lib.withModuleSystemConfig "ssh" config.modules.modules.ssh.knownHosts;
  };
}
