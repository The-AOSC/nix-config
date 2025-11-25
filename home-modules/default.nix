{
  osConfig,
  inputs,
  config,
  lib,
  ...
}: {
  imports = builtins.attrValues (builtins.removeAttrs inputs.self.homeModules ["default"]);
  home.stateVersion = osConfig.system.stateVersion;
  programs.home-manager.enable = true;
  home.activation.removeChannels = lib.hm.dag.entryAfter ["writeBoundary"] ''
    rm -rf ${config.home.homeDirectory}/.nix-defexpr
    rm -rf ${config.home.homeDirectory}/.nix-profile
  '';
}
