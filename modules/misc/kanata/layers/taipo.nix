{lib, ...}: let
  mkTaipo = hand: src-layout: {config, ...}: let
    shift = key: "(multi ${{
      left = "lsft";
      right = "rsft";
    }."${hand}"} ${key})";
    one-shot-timeout = 5000;
    repress-timeout = 200;
    hold-timeout = 300;
    chord-timeout = 200;
    one-shot = action: "(one-shot-release ${toString one-shot-timeout} ${action})";
    tap-hold = tap: hold: "(tap-hold ${toString (repress-timeout + chord-timeout)} ${toString hold-timeout} ${tap} ${hold})";
    tap-hold-fixed-chord = tap-vkey: flag-vkey: hold: {
      raw = ''
        (multi (switch ((input virtual ${flag-vkey})) (on-press press-vkey ${tap-vkey}) break
                       () ${tap-hold ''
            (multi (one-shot-pause-processing 1)
                   (on-press tap-vkey ${tap-vkey}))
          ''
          hold} break)
               (on-release release-vkey ${tap-vkey})
               (one-shot-pause-processing 1)
               (on-press press-vkey ${flag-vkey})
               (on-physical-idle ${toString (repress-timeout + chord-timeout)} release-vkey ${flag-vkey}))
      '';
    };
    base =
      {
        "aux1" = "bspc";
        "aux2" = "del";
        "aux3".raw = tap-hold "rpt-any" "(switch)";
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
        "   ^m vr   " = "\\";
        #"      ^r vp" = "";
        "^i    vr   " = "k";
        "   ^m    vp" = "j";
        "^i       vp" = "w";
        # ===========
        #"vi ^m      " = "";
        "   vm ^r   " = "/";
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
        "^i vm      " = ".";
        "^i vm    vp" = ",";
        "^i vm vr   " = "'";
        "^i    vr vp" = "S-'";
        "^i vm vr vp" = "`";
        "vi vm vr vp" = "S-`";
        "^i    ^r vp" = "S-/";
        "^i ^m ^r vp" = "S-1";
        "^i ^m    vp" = "S-2";
        "      vr ^p" = ";";
        "   vm vr ^p" = "S-;";
        "vi vm    vp" = "S-3";
        "vi    vr vp" = "S-8";
        # ===========
        "aux1 vm      " = "1";
        "aux1    vr   " = "2";
        "aux1       vp" = "3";
        "aux1 vm vr   " = "4";
        "aux1    vr vp" = "5";
        "aux1 ^m      " = "6";
        "aux1    ^r   " = "7";
        "aux1       ^p" = "8";
        "aux1 ^m ^r   " = "9";
        "aux1    ^r ^p" = "0";
        # ===========
        "aux1 vm    vp" = "-";
        "aux1 vm vr vp" = "S--";
        "aux1 ^m    ^p" = "S-=";
        "aux1 ^m ^r ^p" = "=";
        # ===========
        "aux2 vm      " = "S-9";
        "aux2    vr   " = "[";
        "aux2       vp" = "S-[";
        "aux2 vm vr   " = "S-,";
        "aux2 ^m      " = "S-0";
        "aux2    ^r   " = "]";
        "aux2       ^p" = "S-]";
        "aux2 ^m ^r   " = "S-.";
        # ===========
        "aux2 vm vr vp" = "S-\\";
        "aux2 ^m ^r ^p" = "S-7";
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
        "aux3 ^m ^r   " = "S-6";
        "aux3 ^m ^r ^p" = "S-5";
        "aux3    ^r ^p" = "S-4";
        "vi ^m ^r vp".raw = let
          mkLock = data: let
            nop = lib.elemAt data 0;
            vkey = config.virtualKeys.${lib.elemAt data 1}.name;
          in
            lib.optionalString (config.virtualKeys ? ${lib.elemAt data 1}) ''
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
    isBrokenChord = bind: action: (isChord bind) && (lib.isString action);
    convertBind = lib.replaceStrings ["^i" "^m" "^r" "^p" "vi" "vm" "vr" "vp" "aux1" "aux2" "aux3"] src-layout;
    mkBinds = binds: lib.mapAttrs' (bind: action: lib.nameValuePair (convertBind bind) (action.raw or (tap-hold action "XX"))) binds;
    mkFixedChords = binds: {config, ...}: {
      virtualKeys =
        lib.concatMapAttrs (bind: action: {
          "${convertBind bind}".action = action;
          "flag-${convertBind bind}".action = "nop9";
        })
        binds;
      binds = mkBinds (lib.mapAttrs (bind: _: tap-hold-fixed-chord config.virtualKeys.${convertBind bind}.name config.virtualKeys."flag-${convertBind bind}".name "XX") binds);
    };
    mkLayer = binds: {...}: {
      imports = [(mkFixedChords (lib.filterAttrs isBrokenChord binds))];
      binds = mkBinds (lib.filterAttrs (bind: action: !(isBrokenChord bind action)) binds);
    };
  in {
    imports = [(mkLayer base)];
    subLayers.controls = mkLayer controls;
    subLayers.functions = mkLayer functions;
    virtualKeys =
      {
        left = {
          lctl.action = "lctl";
          lsft.action = "lsft";
          lalt.action = "lalt";
          lmet.action = "lmet";
        };
        right = {
          rctl.action = "rctl";
          rsft.action = "rsft";
          ralt.action = "ralt";
          rmet.action = "rmet";
        };
      }."${hand}";
  };
in {
  lib.kanata.layers.taipo = {
    left,
    right,
  }: {config, ...}: {
    options.unlock-mods-action = lib.mkOption {
      type = lib.types.str;
      description = "Action that unlocks mods locked with taipo layer";
      readOnly = true;
    };
    imports = [
      (mkTaipo "left" left)
      (mkTaipo "right" right)
    ];
    config.unlock-mods-action = ''
      (multi ${
        lib.concatMapStringsSep "\n" (vkey: "(on-press release-vkey ${config.virtualKeys.${vkey}.name})")
        ["lctl" "lalt" "lmet" "rsft" "rctl" "ralt" "rmet"]
      })
    '';
  };
}
