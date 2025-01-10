{config, ...}: {
  modules.options.offline-rebuild = {
    userPackages = [];
  };
  nix.extraOptions = config.modules.lib.withModuleSystemConfig "offline-rebuild" ''
    keep-derivations = true
    keep-outputs = true
  '';
}
