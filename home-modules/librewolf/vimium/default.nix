{
  config,
  pkgs,
  lib,
  ...
}: let
  vimium-patched = config.lib.librewolf.patchExtension pkgs.nur.repos.rycee.firefox-addons.vimium [
    ./declarative-vimium.patch
  ] {};
in {
  options.programs.librewolf.profiles = lib.mkOption {
    type = with lib.types;
      attrsOf (
        submodule {
          config = lib.mkIf config.modules.librewolf.enable {
            extensions = {
              packages = [vimium-patched];
              settings."${vimium-patched.addonId}" = {
                force = true;
                settings = {
                  settings = {
                    keyMappings = ''
                      # Insert your preferred key mappings here.
                      mapkey <c-]> <c-[>
                      unmap <<
                      unmap >>
                      unmap '
                      unmap J
                      unmap K
                      map < moveTabLeft
                      map > moveTabRight
                      map ' Marks.activateGotoMode
                      map <c-f> LinkHints.activateModeToOpenInNewForegroundTab
                      map J nextTab
                      map K previousTab
                    '';
                    exclusionRules = [];
                    grabBackFocus = true;
                    hideHud = true;
                    ignoreKeyboardLayout = true;
                    newTabUrl = "about:blank";
                    regexFindMode = true;
                    searchUrl = "https://www.duckduckgo.com/?q=";
                    settingsVersion = "2.3";
                  };
                };
              };
            };
          };
        }
      );
  };
}
