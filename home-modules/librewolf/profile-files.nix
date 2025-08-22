{
  config,
  pkgs,
  lib,
  ...
}: let
  addons = pkgs.nur.repos.rycee.firefox-addons;
in {
  options = with lib.types; {
    programs.librewolf.profiles = lib.mkOption {
      type = attrsOf (submodule ({config, ...}: {
        options = {
          file = lib.mkOption {
            description = "Content of files in profile directory";
            type = attrsOf lines;
          };
          # TODO: can't define this under `extensions` as it's wrapped in coercedTo for legacy support
          extensions'.settings = lib.mkOption {
            description = "desk";
            default = {};
            type = attrsOf (submodule {
              options = {
                shortcuts = lib.mkOption {
                  description = "Attribute set from command to shortcut";
                  type = attrsOf str;
                  default = {};
                };
                tabHideNotification = lib.mkOption {
                  description = "Silence tab hide notification";
                  type = bool;
                  default = false;
                };
              };
            });
          };
        };
        config = {
          file = lib.mkIf config.extensions.force {
            "extension-settings.json" = builtins.toJSON {
              version = 3;
              commands = lib.zipAttrsWith (_: commands: {precedenceList = commands;}) (lib.mapAttrsToList (addonId: extensionSettings:
                lib.mapAttrs (_: shortcut: {
                  enabled = true;
                  id = addonId;
                  value.shortcut = shortcut;
                })
                extensionSettings.shortcuts)
              config.extensions'.settings);
              tabHideNotification = lib.mapAttrs (addonId: _: {
                precedenceList = [
                  {
                    id = addonId;
                    value = true;
                    enabled = true;
                  }
                ];
              }) (lib.filterAttrs (_: extensionSettings: extensionSettings.tabHideNotification) config.extensions'.settings);
            };
          };
        };
      }));
    };
  };
  config = lib.mkIf config.modules.librewolf.enable {
    home.file = lib.mkMerge (lib.mapAttrsToList (
        profileName: profileConfig:
          lib.mapAttrs' (
            fileName: content:
              lib.nameValuePair "${config.programs.librewolf.profilesPath}/${profileConfig.path}/${fileName}" {
                force = true;
                text = content;
              }
          )
          profileConfig.file
      )
      config.programs.librewolf.profiles);
  };
}
