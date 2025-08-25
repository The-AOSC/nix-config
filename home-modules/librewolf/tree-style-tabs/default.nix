{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (pkgs.nur.repos.rycee.firefox-addons) tree-style-tab;
in {
  options.programs.librewolf.profiles = lib.mkOption {
    type = with lib.types;
      attrsOf (
        submodule {
          config = lib.mkIf config.modules.librewolf.enable {
            extensions = {
              packages = [tree-style-tab];
              settings."${tree-style-tab.addonId}" = {
                force = true;
                settings = {
                  notifiedFeaturesVersion = 9;
                  syncAvailableNotified = true;
                };
              };
            };
            extensions' = {
              settings."${tree-style-tab.addonId}" = {
                shortcuts = {
                  newChildTab = "Ctrl+T";
                  newIndependentTab = "Ctrl+Alt+T";
                  newSiblingTab = "Ctrl+Shift+T";
                  simulateDownOnTree = "Alt+J";
                  simulateLeftOnTree = "Alt+H";
                  simulateRightOnTree = "Alt+L";
                  simulateUpOnTree = "Alt+K";
                  tabMoveDown = "Alt+Shift+J";
                  tabMoveUp = "Alt+Shift+K";
                  treeMoveDown = "Alt+Shift+Down";
                  treeMoveUp = "Alt+Shift+Up";
                };
              };
            };
            # https://github.com/piroor/treestyletab/wiki/Code-snippets-for-custom-style-rules#for-userchromecss
            userChrome = ''
              // hide tab bar
              #main-window[tabsintitlebar="true"]:not([extradragspace="true"]) #TabsToolbar > .toolbar-items {
                opacity: 0;
                pointer-events: none;
              }
              #main-window:not([tabsintitlebar="true"]) #TabsToolbar {
                visibility: collapse !important;
              }
              // hide sidebar header for Tree Style Tab
              *|sidebar-header {}
              #sidebar-box[sidebarcommand="treestyletab_piro_sakura_ne_jp-sidebar-action"] #sidebar-header {
                display: none;
              }
            '';
          };
        }
      );
  };
}
