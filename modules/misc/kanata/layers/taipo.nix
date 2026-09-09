{lib, ...}: let
  mkTaipo = hand: src-layout: {config, ...}: let
    shift = key: "${{
      left = "S";
      right = "RS";
    }."${hand}"}-${key}";
    one-shot-timeout = 5000;
    repress-timeout = 200;
    hold-timeout = 300;
    chord-timeout = 200;
    one-shot = action: "(one-shot-release ${toString one-shot-timeout} ${action})";
    tap-hold = tap: hold: "(tap-hold ${toString (repress-timeout + chord-timeout)} ${toString hold-timeout} ${tap} ${hold})";
    tap-hold-fixed-chord = tap-vkey: flag-vkey: hold: unshift-vkey: {
      raw = ''
        (multi (one-shot-pause-processing 1)
          (switch ${
          lib.optionalString (lib.isString unshift-vkey) ''
            ((and (input virtual ${flag-vkey})
                  (or nop0
                      nop4
                      (input virtual ${config.subLayers."!stub".virtualKeys.lsft.name})
                      (input virtual ${config.subLayers."!stub".virtualKeys.rsft.name})))) (on-press press-vkey ${unshift-vkey}) break
          ''
        }
                       ((input virtual ${flag-vkey})) (on-press press-vkey ${tap-vkey}) break
                       () ${tap-hold ''
            (multi (one-shot-pause-processing 1)
                   (switch ${
              lib.optionalString (lib.isString unshift-vkey) ''
                ((or nop0
                     nop4
                     (input virtual ${config.subLayers."!stub".virtualKeys.lsft.name})
                     (input virtual ${config.subLayers."!stub".virtualKeys.rsft.name}))) (on-press tap-vkey ${unshift-vkey}) break
              ''
            }
                           () (on-press tap-vkey ${tap-vkey}) break)
                   )
          ''
          hold} break)
               (on-release release-vkey ${tap-vkey})
               ${lib.optionalString (lib.isString unshift-vkey) ''(on-release release-vkey ${unshift-vkey})''}
               (on-press press-vkey ${flag-vkey})
               (on-physical-idle ${toString (repress-timeout + chord-timeout)} release-vkey ${flag-vkey}))
      '';
    };
    smart-unshift = key: {
      unshift = key;
    };
    base =
      {
        "aux1" = "bspc";
        "aux2" = "del";
        "aux3".raw = tap-hold "rpt-any" "(layer-while-held ${config.subLayers."!stub".name})";
        # ===========
        "^i         " = "i";
        "   ^m      " = "n";
        "      ^r   " = "s";
        "         ^p".raw = tap-hold "r" "(layer-while-held ${config.subLayers.controls.name})";
        "vi         " = "e";
        "   vm      " = "t";
        "      vr   " = "o";
        "         vp".raw = tap-hold "a" "(layer-while-held ${config.subLayers.functions.name})";
        # ===========
        "^i ^m      " = "y";
        "   ^m ^r   " = "p";
        "      ^r ^p" = "b";
        "^i    ^r   " = "f";
        "   ^m    ^p" = "z";
        "^i       ^p" = "g";
        # ===========
        "vi vm      " = "h";
        "   vm vr   " = "u";
        "      vr vp" = "l";
        "vi    vr   " = "c";
        "   vm    vp" = "q";
        "vi       vp" = "d";
        # ===========
        #"^i vm      " = "";
        "   ^m vr   " = smart-unshift "\\";
        #"      ^r vp" = "";
        "^i    vr   " = "k";
        "   ^m    vp" = "j";
        "^i       vp" = "w";
        # ===========
        #"vi ^m      " = "";
        "   vm ^r   " = smart-unshift "/";
        #"      vr ^p" = "";
        "vi    ^r   " = "v";
        "   vm    ^p" = "x";
        "vi       ^p" = "m";
        # ===========
        "vi vm vr   " = "spc";
        "   vm vr vp" = "ret";
        "^i ^m ^r   " = "tab";
        "   ^m ^r ^p" = "esc";
        # ===========
        "^i vm      " = smart-unshift ".";
        "^i vm    vp" = smart-unshift ",";
        "^i vm vr   " = smart-unshift "'";
        "^i    vr vp" = "S-'";
        "^i vm vr vp" = smart-unshift "`";
        "vi vm vr vp" = "S-`";
        "^i    ^r vp" = "S-/";
        "^i ^m ^r vp" = "S-1";
        "^i ^m    vp" = "S-2";
        "      vr ^p" = smart-unshift ";";
        "   vm vr ^p" = "S-;";
        "vi vm    vp" = "S-3";
        "vi    vr vp" = "S-8";
        # ===========
        "aux1 vm      " = smart-unshift "1";
        "aux1    vr   " = smart-unshift "2";
        "aux1       vp" = smart-unshift "3";
        "aux1 vm vr   " = smart-unshift "4";
        "aux1    vr vp" = smart-unshift "5";
        "aux1 ^m      " = smart-unshift "6";
        "aux1    ^r   " = smart-unshift "7";
        "aux1       ^p" = smart-unshift "8";
        "aux1 ^m ^r   " = smart-unshift "9";
        "aux1    ^r ^p" = smart-unshift "0";
        # ===========
        "aux1 vm    vp" = smart-unshift "-";
        "aux1 vm vr vp" = shift "-";
        "aux1 ^m    ^p" = shift "=";
        "aux1 ^m ^r ^p" = smart-unshift "=";
        # ===========
        "aux2 vm      " = shift "9";
        "aux2    vr   " = smart-unshift "[";
        "aux2       vp" = shift "[";
        "aux2 vm vr   " = shift ",";
        "aux2 ^m      " = shift "0";
        "aux2    ^r   " = smart-unshift "]";
        "aux2       ^p" = shift "]";
        "aux2 ^m ^r   " = shift ".";
        # ===========
        "aux2 vm vr vp" = shift "\\";
        "aux2 ^m ^r ^p" = shift "7";
        # ===========
        "aux3 vm      " = "left";
        "aux3    vr   " = "down";
        "aux3       vp" = "right";
        "aux3 ^m      " = "home";
        "aux3    ^r   " = "up";
        "aux3       ^p" = "end";
        "aux3 vm vr   " = "pgdn";
        "aux3    vr vp" = "pgup";
        # ===========
        "aux3 ^m ^r   " = shift "6";
        "aux3 ^m ^r ^p" = shift "5";
        "aux3    ^r ^p" = shift "4";
        "vi ^m ^r vp".raw = let
          mkLock = data: let
            nop = lib.elemAt data 0;
            vkey = config.subLayers."!stub".virtualKeys.${lib.elemAt data 1}.name;
          in ''
            (${nop}) (on-press press-vkey ${vkey}) fallthrough
            ((not ${nop})) (on-press release-vkey ${vkey}) fallthrough
          '';
        in ''
          (switch ${lib.concatMapStringsSep "\n" mkLock [
            ["nop0" "lsft"]
            ["nop1" "lctl"]
            ["nop2" "lalt"]
            ["nop3" "lmet"]
            ["nop4" "rsft"]
            ["nop5" "rctl"]
            ["nop6" "ralt"]
            ["nop7" "rmet"]
          ]})
        '';
      }
      // {
        left = {
          "vi ^m      ".raw = "(multi ${one-shot "nop0"} ${one-shot "lsft"})";
          "      ^r vp".raw = "(multi ${one-shot "nop1"} ${one-shot "lctl"})";
          "vi ^m ^r   ".raw = "(multi ${one-shot "nop2"} ${one-shot "lalt"})";
          "   ^m ^r vp".raw = "(multi ${one-shot "nop3"} ${one-shot "lmet"})";
        };
        right = {
          "vi ^m      ".raw = "(multi ${one-shot "nop4"} ${one-shot "rsft"})";
          "      ^r vp".raw = "(multi ${one-shot "nop5"} ${one-shot "rctl"})";
          "vi ^m ^r   ".raw = "(multi ${one-shot "nop6"} ${one-shot "ralt"})";
          "   ^m ^r vp".raw = "(multi ${one-shot "nop7"} ${one-shot "rmet"})";
        };
      }."${hand}";
    controls = {
      "^i      " = "volu";
      "vi      " = "vold";
      "   ^m   " = "mute";
      "   vm   " = "XX";
      "      ^r" = "bru";
      "      vr" = "brdn";
      "   ^m ^r" = "powr";
      "   vm vr" = "prnt";
      "^i ^m ^r" = "powr";
      "vi vm vr" = "prnt";
      "^p" = "XX";
      "vp" = "XX";
      "aux1" = "XX";
      "aux2" = "XX";
      "aux3" = "XX";
    };
    functions = {
      "vi      " = "f1";
      "   vm   " = "f2";
      "      vr" = "f3";
      "^i      " = "f4";
      "   ^m   " = "f5";
      "      ^r" = "f6";
      "vi vm   " = "f7";
      "   vm vr" = "f8";
      "^i ^m   " = "f9";
      "   ^m ^r" = "f10";
      "vi vm vr" = "f11";
      "^i ^m ^r" = "f12";
      "^p" = "XX";
      "vp" = "XX";
      "aux1" = "XX";
      "aux2" = "XX";
      "aux3" = "XX";
    };
    isChord = bind: lib.hasInfix " " (lib.trim bind);
    isBrokenChord = bind: action: (isChord bind) && ((lib.isString action) || (action?unshift));
    convertBind = lib.replaceStrings ["^i" "^m" "^r" "^p" "vi" "vm" "vr" "vp" "aux1" "aux2" "aux3"] src-layout;
    mkBinds = binds: lib.mapAttrs' (bind: action: lib.nameValuePair (convertBind bind) (action.raw or (tap-hold action "XX"))) binds;
    mkFixedChords = binds: {config, ...}: {
      virtualKeys = lib.concatMapAttrs (bind: action:
        {
          "${convertBind bind}".action =
            if lib.isAttrs action
            then action.unshift
            else action;
          "flag-${convertBind bind}".action = "nop9";
        }
        // (lib.optionalAttrs (lib.isAttrs action) {
          "${convertBind bind}-unshift".action = "L3S-${action.unshift}";
        }))
      binds;
      binds = mkBinds (lib.mapAttrs (bind: action:
        tap-hold-fixed-chord config.virtualKeys.${convertBind bind}.name config.virtualKeys."flag-${convertBind bind}".name "XX" (
          if lib.isAttrs action
          then config.virtualKeys."${convertBind bind}-unshift".name
          else null
        ))
      binds);
    };
    mkLayer = binds: {...}: {
      imports = [(mkFixedChords (lib.filterAttrs isBrokenChord binds))];
      binds = mkBinds (lib.filterAttrs (bind: action: !(isBrokenChord bind action)) binds);
    };
  in {
    imports = [(mkLayer base)];
    subLayers.controls = mkLayer controls;
    subLayers.functions = mkLayer functions;
  };
in {
  lib.kanata.layers.taipo = {
    left ? null,
    right ? null,
  }: {config, ...}: {
    options.unlock-mods-action = lib.mkOption {
      type = lib.types.str;
      description = "Action that unlocks mods locked with taipo layer";
      readOnly = true;
    };
    imports = lib.concatLists [
      (lib.optional (left != null) (mkTaipo "left" left))
      (lib.optional (right != null) (mkTaipo "right" right))
    ];
    config = {
      # those virtualkeys need to be defined early, so add ! to layer name to make it appear earlier
      subLayers."!stub".virtualKeys = {
        lctl.action = "lctl";
        lsft.action = "lsft";
        lalt.action = "lalt";
        lmet.action = "lmet";
        rctl.action = "rctl";
        rsft.action = "rsft";
        ralt.action = "ralt";
        rmet.action = "rmet";
      };
      unlock-mods-action = ''
        (multi ${
          lib.concatMapStringsSep "\n" (vkey: "(on-press release-vkey ${config.subLayers."!stub".virtualKeys.${vkey}.name})")
          ["lctl" "lalt" "lmet" "rsft" "rctl" "ralt" "rmet"]
        })
      '';
    };
  };
}
