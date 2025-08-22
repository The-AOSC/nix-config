{
  config,
  pkgs,
  lib,
  ...
}: {
  modules.librewolf.globalConfig = let
    simple-tab-groups-patched = config.lib.librewolf.patchExtension pkgs.nur.repos.rycee.firefox-addons.simple-tab-groups [
      ./simple-tab-groups-static-configuration.patch
    ] {};
  in {
    settings = {
      "svg.context-properties.content.enabled" = true; # fix Simple Tab Groups icons in dark mode
    };
    extensions = {
      packages = [simple-tab-groups-patched];
      settings."${simple-tab-groups-patched.addonId}" = {
        force = lib.mkForce false; # stores tab group data
      };
    };
    extensions' = {
      settings."${simple-tab-groups-patched.addonId}" = {
        shortcuts = {
          _execute_browser_action = ""; # Open popup
          _execute_sidebar_action = "F4"; # Open sidebar
        };
        tabHideNotification = true;
      };
    };
    userChrome = ''
      // hide sidebar header for Simple Tab Groups
      *|sidebar-header {}
      #sidebar-box[sidebarcommand="simple-tab-groups_drive4ik-sidebar-action"] #sidebar-header {
        display: none;
      }
    '';
  };
}
