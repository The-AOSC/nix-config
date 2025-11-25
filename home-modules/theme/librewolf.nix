{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: {
  options.programs.librewolf.profiles = lib.mkOption {
    type = with lib.types;
      attrsOf (
        submodule (
          {name, ...}: let
            inherit (config.catppuccin.librewolf.profiles."${name}") accent flavor;
            palette = (lib.importJSON "${config.catppuccin.sources.palette}/palette.json")."${flavor}".colors;
          in {
            config = lib.mkIf (config.modules.theme.enable && config.catppuccin.librewolf.profiles."${name}".enable) {
              extensions = {
                packages = [
                  pkgs.nur.repos.rycee.firefox-addons.firefox-color
                  pkgs.stylus
                ];
                settings = {
                  "${pkgs.nur.repos.rycee.firefox-addons.vimium.addonId}".settings = {
                    # TODO: remove hardcoded color definitions after upstream fix
                    settings.userDefinedLinkHintCss =
                      builtins.readFile "${inputs.catppuccin-vimium}/themes/catppuccin-vimium-${flavor}.css"
                      + ''
                        /* Catppuccin ${flavor} Palette Fix */
                        :root {
                          --vimium-subtext0: ${palette.subtext0.hex};
                          --vimium-subtext1: ${palette.subtext1.hex};
                          --vimium-surface2: ${palette.surface2.hex};
                        }
                      '';
                  };
                  "${pkgs.nur.repos.rycee.firefox-addons.darkreader.addonId}".settings = {
                    theme = {
                      # https://github.com/catppuccin/dark-reader/blob/098cf0c90aec85870c7fbdcfac4a315f4977fcb1/dark-reader.tera#L45-L53
                      darkSchemeBackgroundColor = palette.base.hex;
                      darkSchemeTextColor = palette.text.hex;
                      selectionColor = palette.surface2.hex;
                    };
                  };
                  "${pkgs.stylus.addonId}" = {
                    force = true;
                    settings = lib.listToAttrs (lib.imap1
                      (id: style:
                        lib.nameValuePair "style-${builtins.toString id}" (lib.recursiveUpdate
                          style
                          {
                            inherit id;
                            usercssData.vars = {
                              accentColor.value = accent;
                              darkFlavor.value = flavor;
                              lightFlavor.value = flavor;
                            };
                          }))
                      (lib.filter
                        (style: style ? usercssData)
                        (builtins.fromJSON (builtins.readFile "${pkgs.catppuccin-userstyles}/import.json"))));
                  };
                };
              };
            };
          }
        )
      );
  };
}
