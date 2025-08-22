{
  config,
  pkgs,
  lib,
  ...
}: {
  modules.librewolf.globalConfig = let
    vimium-patched = config.lib.librewolf.patchExtension pkgs.nur.repos.rycee.firefox-addons.vimium [
      ./declarative-vimium.patch
    ] {};
  in {
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
