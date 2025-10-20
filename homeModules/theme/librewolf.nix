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
                    disabledFor = let
                      lesscData =
                        lib.mapAttrsToList (name: style: {
                          source = style.sourceCode;
                          args = lib.concatStringsSep " " (
                            lib.mapAttrsToList (var: value: let
                              v = value.value or null;
                              d = value.default;
                            in "--global-var=${var}=${builtins.toJSON (
                              if v == null
                              then d
                              else v
                            )}")
                            style.usercssData.vars
                          );
                        })
                        (lib.filterAttrs (name: style: style ? usercssData)
                          (config.programs.librewolf.profiles."${name}".extensions.settings."${pkgs.stylus.addonId}".settings or {}));
                      stylusSites =
                        pkgs.runCommand "stylus-sites" {
                          nativeBuildInputs = with pkgs; [
                            jq
                            lessc
                          ];
                          lesscData = builtins.toJSON lesscData;
                          passAsFile = [
                            "lesscData"
                          ];
                        } ''
                          cp ${pkgs.writeText "lesscData.json" (builtins.toJSON lesscData)} lessc-data.json
                          for i in $(seq 0 ${builtins.toString ((builtins.length lesscData) - 1)}); do
                            echo "Parsing [$i/${builtins.toString (builtins.length lesscData)}]..." >&2
                            jq ".[$i].source" -r $lesscDataPath | lessc - $(jq ".[$i].args" -r $lesscDataPath) | grep -Po '@-moz-document.*{$' | grep -Po '(domain|url|regexp|url-prefix)\(.*?".*?".*?\)'
                          done | sort > $out
                        '';
                      sites = lib.filter (site: site != "") (lib.splitString "\n" (builtins.readFile stylusSites));
                    in
                      lib.filter lib.isString (lib.map (
                          site: let
                            info = lib.match ''(domain|regexp|url|url-prefix)\(("(.*)")\)'' site;
                            singleEscape = str: lib.isList (lib.match ''.*([^\\]|^)\\([^\\]|$).*'' str);
                            type = builtins.elemAt info 0;
                            valueParsed = builtins.fromJSON (builtins.elemAt info 1);
                            valueRaw = builtins.elemAt info 2;
                            value =
                              if singleEscape valueRaw
                              then valueRaw
                              else valueParsed;
                          in
                            if type == "regexp"
                            then "/${value}/"
                            else value
                        )
                        sites);
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
