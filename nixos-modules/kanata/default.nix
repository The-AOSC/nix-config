{
  config,
  lib,
  ...
}:
with config.lib.kanata; {
  imports = lib.mapAttrsToList (path: type: ./layouts + "/${path}") (builtins.readDir ./layouts);
  options = {
    modules.kanata = {
      enable = lib.mkEnableOption "kanata";
      layers = lib.mkOption {
        type = lib.types.attrs;
        visible = false;
      };
      keyboards = lib.mkOption {
        type = with lib.types;
          attrsOf (submodule {
            options = {
              devices = lib.mkOption {
                type = with lib.types; listOf str;
                description = "Paths to keyboard devices";
                default = [];
              };
              extraConfig = lib.mkOption {
                type = lib.types.lines;
                description = "Extra kanata configuration";
                default = "";
              };
              layers = lib.mkOption {
                type = with lib.types;
                  attrsOf (coercedTo (listOf (listOf (nullOr str))) coerceLayer (attrsOf str));
                description = "Layers mapping";
                default = {};
              };
              defaultLayer = lib.mkOption {
                type = lib.types.str;
                description = "Default layer";
              };
            };
          });
        description = "Keyboard configurations";
      };
    };
  };
  config = let
    enable = config.modules.kanata.enable;
  in {
    lib.kanata = {
      layers = config.modules.kanata.layers;
      coerceLayer = list:
        if (lib.isAttrs list)
        then list
        else let
          from = lib.elemAt list 0;
          to = lib.elemAt list 1;
        in
          assert (lib.length from) == (lib.length to);
            lib.filterAttrs (_: lib.isString)
            (
              lib.listToAttrs (lib.zipListsWith (name: value:
                  assert (lib.isString name) && ((lib.isString value) || (builtins.isNull value)); {
                    inherit name value;
                  })
                from
                to)
            );
      mergeTapHold = tap: hold:
        lib.mapAttrs (_: {
          tap ? "XX",
          hold ? "XX",
        }: "(tap-hold 200 250 ${tap} ${hold})")
        (
          lib.recursiveUpdate
          (lib.mapAttrs (_: value: {tap = value;}) (coerceLayer tap))
          (lib.mapAttrs (_: value: {hold = value;}) (coerceLayer hold))
        );
      mergeLayers = l1: l2: (coerceLayer l1) // (coerceLayer l2);
    };
    services.kanata = lib.mkIf enable {
      enable = true;
      keyboards =
        lib.mapAttrs (name: conf: {
          inherit (conf) devices;
          extraDefCfg = ''
            log-layer-changes no
            process-unmapped-keys yes
          '';
          config = let
            parse-layer = name: mappings: ''
              (deflayermap (${name}) ${lib.concatLines (lib.mapAttrsToList (from: to: "${from} ${to}")
                  mappings)})
            '';
            default = conf.defaultLayer;
          in ''
            (defsrc)
            ${conf.extraConfig}
            ${parse-layer default conf.layers."${default}"}
            ${lib.concatLines (lib.mapAttrsToList parse-layer (lib.filterAttrs (name: _: name != default) conf.layers))}
          '';
        })
        config.modules.kanata.keyboards;
    };
    /*
    (defvirtualkeys
      vkey-mouse-left  (tap-hold 200 200 (movemouse-left  200 1) (movemouse-left  20 1))
      vkey-mouse-right (tap-hold 200 200 (movemouse-right 200 1) (movemouse-right 20 1))
      vkey-mouse-up    (tap-hold 200 200 (movemouse-up    200 1) (movemouse-up    20 1))
      vkey-mouse-down  (tap-hold 200 200 (movemouse-down  200 1) (movemouse-down  20 1)))
    (deflayermap (mouse-ctl)
      n (tap-hold 200 200 (mwheel-down  200 120) (mwheel-down  20 12))
      p (tap-hold 200 200 (mwheel-up    200 120) (mwheel-up    20 12))
      h (tap-hold 200 200 (mwheel-left  200 120) (mwheel-left  20 12))
      l (tap-hold 200 200 (mwheel-right 200 120) (mwheel-right 20 12))
      kp7 (multi (on-press press-vkey vkey-mouse-up)    (on-release release-vkey vkey-mouse-up)
                 (on-press press-vkey vkey-mouse-left)  (on-release release-vkey vkey-mouse-left))
      kp8 (multi (on-press press-vkey vkey-mouse-up)    (on-release release-vkey vkey-mouse-up))
      kp9 (multi (on-press press-vkey vkey-mouse-up)    (on-release release-vkey vkey-mouse-up)
                 (on-press press-vkey vkey-mouse-right) (on-release release-vkey vkey-mouse-right))
      kp4 (multi (on-press press-vkey vkey-mouse-left)  (on-release release-vkey vkey-mouse-left))
      kp6 (multi (on-press press-vkey vkey-mouse-right) (on-release release-vkey vkey-mouse-right))
      kp1 (multi (on-press press-vkey vkey-mouse-down)  (on-release release-vkey vkey-mouse-down)
                 (on-press press-vkey vkey-mouse-left)  (on-release release-vkey vkey-mouse-left))
      kp2 (multi (on-press press-vkey vkey-mouse-down)  (on-release release-vkey vkey-mouse-down))
      kp3 (multi (on-press press-vkey vkey-mouse-down)  (on-release release-vkey vkey-mouse-down)
                 (on-press press-vkey vkey-mouse-right) (on-release release-vkey vkey-mouse-right)))
    */
  };
}
