{
  config,
  pkgs,
  lib,
  ...
}: let
  darkreader-patched =
    config.lib.librewolf.patchExtension pkgs.nur.repos.rycee.firefox-addons.darkreader [
      ./darkreader-no-install-help.patch
    ] {
      prePatch = ''
        ${pkgs.dos2unix}/bin/dos2unix background/index.js
      '';
    };
in {
  options.programs.librewolf.profiles = lib.mkOption {
    type = with lib.types;
      attrsOf (
        submodule {
          config = lib.mkIf config.modules.librewolf.enable {
            extensions = {
              packages = [darkreader-patched];
              settings."${darkreader-patched.addonId}" = {
                force = true;
                settings = {
                  enabledByDefault = true;
                  syncSettings = false;
                };
              };
            };
          };
        }
      );
  };
}
