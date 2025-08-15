{
  osConfig,
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    modules.librewolf.enable = lib.mkEnableOption "librewolf";
  };
  config = let
    addons = pkgs.nur.repos.rycee.firefox-addons;
    patchExtension = extension: patches: extra: let
      extensionPath = "extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}";
    in
      pkgs.stdenv.mkDerivation ({
          name = "${extension.name}-patched";
          src = "${extension}/share/mozilla/${extensionPath}/${extension.addonId}.xpi";
          unpackPhase = ''
            runHook preUnpack
            mkdir extension
            cd extension
            ${pkgs.unzip}/bin/unzip $src
            runHook postUnpack
          '';
          installPhase = ''
            runHook preInstall
            mkdir -p $out/share/mozilla/${extensionPath}
            ${pkgs.zip}/bin/zip -r $out/share/mozilla/${extensionPath}/${extension.addonId}.xpi -- *
            runHook postInstall
          '';
          inherit patches;
          inherit (extension) meta;
          passthru = {
            inherit (extension) addonId mozPermissions;
          };
        }
        // extra);
    darkreader-patched =
      patchExtension addons.darkreader [
        ./darkreader-no-install-help.patch
      ] {
        prePatch = ''
          ${pkgs.dos2unix}/bin/dos2unix background/index.js
        '';
      };
    simple-tab-groups-patched = patchExtension addons.simple-tab-groups [
      ./simple-tab-groups-static-configuration.patch
    ] {};
    vimium-patched = patchExtension addons.vimium [
      ./declarative-vimium.patch
    ] {};
  in
    lib.mkIf config.modules.librewolf.enable {
      programs.librewolf = {
        enable = true;
        package = pkgs.librewolf.overrideAttrs (old: {
          # https://github.com/nilcons/firefox-hacks
          patches = [
            ./keybindings.patch
          ];
          buildCommand = ''
            ${old.buildCommand or ""}
            mkdir /build/browser-omni.ja
            cd /build/browser-omni.ja
            ${pkgs.unzip}/bin/unzip $out/lib/librewolf/browser/omni.ja || true
            rm $out/lib/librewolf/browser/omni.ja
            cd /build
            source $stdenv/setup
            patchPhase
            cd /build/browser-omni.ja
            ${pkgs.zip}/bin/zip $out/lib/librewolf/browser/omni.ja -0DXr -- *
          '';
        });
        profiles = let
          global-config = {
            settings = {
              # about:config
              "browser.startup.page" = 3; # restore last session
              "browser.tabs.closeWindowWithLastTab" = false; # keep window open when last tab is closed
              "browser.toolbars.bookmarks.visibility" = "never";
              "browser.translations.automaticallyPopup" = false;
              "devtools.toolbox.host" = "window"; # display in separate window
              "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org"; # dark theme
              "extensions.autoDisableScopes" = 0; # automatically enable declarative extensions
              "privacy.resistFingerprinting" = false; # has many issues with extensions
              "svg.context-properties.content.enabled" = true; # fix Simple Tab Groups icons in dark mode
              "toolkit.legacyUserProfileCustomizations.stylesheets" = true; # enable userChrome.css
              "xpinstall.signatures.required" = false; # allow unsigned extensions
            };
            extensions = {
              force = true;
              packages = [
                addons.tree-style-tab
                darkreader-patched
                simple-tab-groups-patched
                vimium-patched
              ];
              settings = let
                settings = settings: {
                  force = true;
                  inherit settings;
                };
              in {
                "${addons.tree-style-tab.addonId}" = settings {
                  notifiedFeaturesVersion = 9;
                  syncAvailableNotified = true;
                };
                "${darkreader-patched.addonId}" = settings {};
                "${simple-tab-groups-patched.addonId}" = {
                  force = lib.mkForce false; # stores tab group data
                };
                "${vimium-patched.addonId}" = settings {
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
            search = {
              force = true;
              default = "ddg";
              privateDefault = "ddg";
              engines = {
                ddg = {};
              };
            };
            userChrome = ''
              // https://github.com/piroor/treestyletab/wiki/Code-snippets-for-custom-style-rules#for-userchromecss
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
              #sidebar-box[sidebarcommand="simple-tab-groups_drive4ik-sidebar-action"] #sidebar-header {
                display: none;
              }
            '';
          };
        in
          lib.mapAttrs (name: config: lib.mkMerge [global-config config]) {
            default = {
              settings = {
                "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
              };
            };
            private = {
              id = 1;
              settings = {
                "privacy.clearOnShutdown_v2.browsingHistoryAndDownloads" = true;
                "privacy.clearOnShutdown_v2.cache" = true;
                "privacy.clearOnShutdown_v2.cookiesAndStorage" = true;
                "privacy.clearOnShutdown_v2.formdata" = true;
                "privacy.clearOnShutdown_v2.historyFormDataAndDownloads" = true;
                "privacy.clearOnShutdown_v2.siteSettings" = true;
              };
            };
            tor = {
              id = 2;
              settings = {
                "network.proxy.socks" = "localhost";
                "network.proxy.socks_port" = osConfig.services.tor.client.socksListenAddress.port;
                "network.proxy.type" = 1;
                "privacy.clearOnShutdown_v2.browsingHistoryAndDownloads" = true;
                "privacy.clearOnShutdown_v2.cache" = true;
                "privacy.clearOnShutdown_v2.cookiesAndStorage" = true;
                "privacy.clearOnShutdown_v2.formdata" = true;
                "privacy.clearOnShutdown_v2.historyFormDataAndDownloads" = true;
                "privacy.clearOnShutdown_v2.siteSettings" = true;
              };
            };
          };
      };
      home.file = lib.mkMerge (lib.mapAttrsToList (
          profileName: profileConfig:
            lib.mapAttrs' (
              fileName: content:
                lib.nameValuePair "${config.programs.librewolf.profilesPath}/${profileConfig.path}/${fileName}" {
                  force = true;
                  text = content;
                }
            ) {
              # force declarative settings
              "compatibility.ini" = "";
              "prefs.js" = "";
              "storage-sync-v2.sqlite" = "";
              "storage-sync-v2.sqlite-shm" = "";
              "storage-sync-v2.sqlite-wal" = "";
              # extensions settings
              "extension-settings.json" = builtins.toJSON {
                version = 3;
                commands = lib.zipAttrsWith (_: commands: {precedenceList = commands;}) (lib.mapAttrsToList (addonId: commands:
                  lib.mapAttrs (command: shortcut: {
                    enabled = true;
                    id = addonId;
                    value.shortcut = shortcut;
                  })
                  commands) {
                  "${simple-tab-groups-patched.addonId}" = {
                    _execute_browser_action = ""; # Open popup
                    _execute_sidebar_action = "F4"; # Open sidebar
                  };
                  "${addons.tree-style-tab.addonId}" = {
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
                });
                tabHideNotification = {
                  "${simple-tab-groups-patched.addonId}" = {
                    precedenceList = [
                      {
                        id = "${simple-tab-groups-patched.addonId}";
                        value = true;
                        enabled = true;
                      }
                    ];
                  };
                };
              };
            }
        )
        config.programs.librewolf.profiles);
      home.persistence."/persist" = {
        directories = [
          ".librewolf/default"
        ];
      };
    };
}
