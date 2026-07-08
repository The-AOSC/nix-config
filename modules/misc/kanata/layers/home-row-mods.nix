{
  lib.kanata.layers.home-row-mods = {
    config,
    lib,
    ...
  }: let
    src-layout =
      ["esc" "grv" "1" "2" "3" "4" "5" "6" "7" "8" "9" "0" "-"]
      ++ ["tab" "q" "w" "e" "r" "t" "y" "u" "i" "o" "p" "["]
      ++ ["caps" "a" "s" "d" "f" "g" "h" "j" "k" "l" ";" "'"]
      ++ ["z" "x" "c" "v" "b" "n" "m" "," "." "/"]
      ++ ["spc"];
    holds = {
      "a" = "lmet";
      "s" = "lalt";
      "d" = "lsft";
      "f" = "lctl";
      "j" = "rctl";
      "k" = "rsft";
      "l" = "ralt";
      ";" = "rmet";
      "spc" = "(layer-while-held ${config.subLayers.level1.name})";
      "caps" = "(layer-while-held ${config.subLayers.level2.name})";
      "esc" = "(layer-while-held ${config.subLayers.level2.name})";
      "tab" = "(layer-while-held ${config.subLayers.level3.name})";
    };
    mkBinds = layer-layout:
      assert (lib.length src-layout) == (lib.length layer-layout);
        (lib.foldr (a: b: a // b) {} (lib.zipListsWith (from: to: {
            ${from} = "(tap-hold 200 250 ${
              if to == null
              then "XX"
              else to
            } ${holds.${from} or "XX"})";
          })
          src-layout
          layer-layout))
        // {
          "___" = "XX";
        };
  in {
    binds = mkBinds (
      ["esc" "=" "1" "2" "3" "4" "5" "6" "7" "8" "9" "0" "-"]
      ++ ["tab" "q" "w" "e" "r" "t" "y" "u" "i" "o" "p" "\\"]
      ++ ["esc" "a" "s" "d" "f" "g" "h" "j" "k" "l" ";" "'"]
      ++ ["z" "x" "c" "v" "b" "n" "m" "," "." "/"]
      ++ ["spc"]
    );
    subLayers = {
      level1.binds = mkBinds (
        [null "f1" "f2" "f3" "f4" "f5" "f6" "f7" "f8" "f9" "f10" "f11" "f12"]
        ++ [null null null "end" null null null "[" "]" "grv" "pgup" null]
        ++ [null "home" null "del" "right" null "bspc" "ret" null null null null]
        ++ [null null null null "left" "pgdn" null null null null]
        ++ [null]
      );
      level2.binds = mkBinds (
        [null null null null "brdn" "bru" null null null null "vold" "volu" null]
        ++ [null null null null "ins" null null "kp+" "kp-" null null null]
        ++ [null null "prnt" null null null "left" "down" "up" "right" "ret" null]
        ++ [null null null null null null "mute" null null null]
        ++ ["spc"]
      );
      level3.binds = mkBinds (
        [null null null null null null null null "kp7" "kp8" "kp9" null "powr"]
        ++ [null null null "e" null null null "kp4" "kp5" "kp6" null null]
        ++ [null "a" null "d" "f" null null "kp1" "kp2" "kp3" null null]
        ++ [null null "c" null "b" null "kp0" "kp." "kprt" null]
        ++ ["spc"]
      );
    };
  };
}
