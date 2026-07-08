{
  den,
  lib,
  ...
}: let
  virtualKeyType = namePrefix:
    lib.types.submodule ({name, ...}: {
      options = {
        action = lib.mkOption {
          type = lib.types.str;
          description = "Action bound to vkey";
        };
        name = lib.mkOption {
          type = lib.types.str;
          description = "Key name used in configuration";
          readOnly = true;
        };
      };
      config.name = "auto-vkey${namePrefix}-${lib.replaceString "-" "_" name}";
    });
  layerType = namePrefix:
    lib.types.submodule ({
      config,
      name,
      ...
    }: let
      newPrefix = "${namePrefix}-${lib.replaceString "-" "_" name}";
    in {
      options = {
        subLayers = lib.mkOption {
          type = lib.types.attrsOf (layerType newPrefix);
          description = "Extra layers, defined by parent layer";
          default = {};
        };
        name = lib.mkOption {
          type = lib.types.str;
          description = "Layer name used in configuration";
          readOnly = true;
        };
        virtualKeys = lib.mkOption {
          type = lib.types.attrsOf (virtualKeyType newPrefix);
          description = "Required virtual keys";
          default = {};
        };
        binds = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          description = "Binds active on this layer";
          default = {};
        };
      };
      config.name = "auto-layer${newPrefix}";
    });
  keyboardType = lib.types.submodule ({config, ...}: {
    options = {
      layers = lib.mkOption {
        type = lib.types.attrsOf (layerType "");
        description = "Defined toplevel layers";
      };
      defaultLayer = lib.mkOption {
        type = lib.types.str;
        description = "Layer to activate by default";
      };
      devices = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "Paths to keyboard devices";
        default = [];
      };
      extraConfig = lib.mkOption {
        type = lib.types.lines;
        description = "Extra kanata configuration";
        default = "";
      };
      finalConfig = lib.mkOption {
        type = lib.types.lines;
        readOnly = true;
        internal = true;
      };
      port = lib.mkOption {
        type = lib.types.nullOr lib.types.port;
        description = "Kanata TCP server port";
        default = null;
      };
    };
    config = {
      finalConfig = let
        allLayers = let
          recurse = layers: layers ++ (lib.concatMap (layer: recurse (lib.attrValues layer.subLayers)) layers);
        in
          recurse (lib.attrValues config.layers);
        chords = lib.foldr lib.recursiveUpdate {} (
          lib.concatLists (
            lib.map (
              layer:
                lib.mapAttrsToList (
                  bind: action:
                    lib.optionalAttrs (lib.hasInfix " " bind) {
                      ${bind}.${layer.name} = action;
                    }
                )
                layer.binds
            )
            allLayers
          )
        );
        parse-layer = layer: ''
          (deflayermap (${layer.name})
            ${lib.concatMapAttrsStringSep "" (bind: action: lib.optionalString (!(lib.hasInfix " " bind)) "${bind} ${action}\n") layer.binds})
        '';
      in ''
        (defsrc)
        ${config.extraConfig}
        (defvirtualkeys ${lib.concatMapStringsSep "\n" (layer: lib.concatMapAttrsStringSep "\n" (_: vkey: "${vkey.name} ${vkey.action}") layer.virtualKeys) allLayers})
        (defchordsv2 ${lib.concatMapAttrsStringSep "" (bind: layers: ''
            (${bind}) (switch ${
              lib.concatMapAttrsStringSep "" (layer: action: ''
                ((layer ${layer})) ${action} break
              '')
              layers
            }) 200 all-released (${
              lib.concatStringsSep " " (lib.subtractLists (lib.attrNames layers) (lib.map (layer: layer.name) allLayers))
            })
          '')
          chords})
        ${lib.concatMapStrings parse-layer ((lib.filter (layer: layer.name == config.defaultLayer) allLayers) ++ (lib.filter (layer: layer.name != config.defaultLayer) allLayers))}
      '';
    };
  });
in {
  options.lib.kanata = {
    layers = lib.mkOption {
      type = lib.types.attrs;
      description = "Reusable layers";
      default = {};
    };
    layouts = lib.mkOption {
      type = lib.types.attrs;
      description = "Ready made layouts";
      default = {};
    };
  };
  config = {
    den.schema.host = {
      options.kanata.keyboards = let
      in
        lib.mkOption {
          type = lib.types.attrsOf keyboardType;
          description = "Kanata keyboards configuration";
          default = {};
        };
      includes = [
        den.aspects.kanata
      ];
    };
    den.aspects.kanata = {host, ...}: {
      nixos = lib.optionalAttrs (host.kanata.keyboards != {}) {
        services.kanata = {
          enable = true;
          keyboards =
            lib.mapAttrs (_: config: {
              extraDefCfg = ''
                concurrent-tap-hold yes
                log-layer-changes no
                process-unmapped-keys yes
              '';
              config = config.finalConfig;
              port = config.port;
            })
            host.kanata.keyboards;
        };
      };
    };
  };
}
