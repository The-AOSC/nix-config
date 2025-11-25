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
            description = "Attribute set of files to link into profile directory";
            type = attrsOf (
              submodule (
                {config, ...}: {
                  options = {
                    text = lib.mkOption {
                      description = "Text of the file";
                      type = nullOr lines;
                    };
                    json = lib.mkOption {
                      description = "JSON content of";
                      type = nullOr (pkgs.formats.json {}).type;
                    };
                  };
                  config = {
                    text = lib.mkDefault (builtins.toJSON config.json);
                  };
                }
              )
            );
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
              };
            });
          };
        };
        config = {
          file = let
            commands = lib.zipAttrsWith (_: commands: {precedenceList = commands;}) (lib.mapAttrsToList (addonId: extensionSettings:
              lib.mapAttrs (_: shortcut: {
                enabled = true;
                id = addonId;
                value.shortcut = shortcut;
              })
              extensionSettings.shortcuts)
            config.extensions'.settings);
          in
            lib.mkIf (config.extensions.force && (commands != {})) {
              "extension-settings.json".json = let
              in {
                version = 3;
                inherit commands;
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
                inherit (content) text;
              }
          )
          profileConfig.file
      )
      config.programs.librewolf.profiles);
  };
}
