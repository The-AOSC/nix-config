{
  config,
  lib,
  ...
}: {
  modules.kanata.layers.homeRowMods = with config.lib.kanata; let
    src-layout =
      ["grv" "1" "2" "3" "4" "5" "6" "7" "8" "9" "0" "-"]
      ++ ["tab" "q" "w" "e" "r" "t" "y" "u" "i" "o" "p" "["]
      ++ ["caps" "a" "s" "d" "f" "g" "h" "j" "k" "l" ";" "'"]
      ++ ["z" "x" "c" "v" "b" "n" "m" "," "." "/"]
      ++ ["spc"];
  in rec {
    base = [
      src-layout
      (
        ["=" "1" "2" "3" "4" "5" "6" "7" "8" "9" "0" "-"]
        ++ ["tab" "q" "w" "e" "r" "t" "y" "u" "i" "o" "p" "\\"]
        ++ ["esc" "a" "s" "d" "f" "g" "h" "j" "k" "l" ";" "'"]
        ++ ["z" "x" "c" "v" "b" "n" "m" "," "." "/"]
        ++ ["spc"]
      )
    ];
    level1 = [
      src-layout
      (
        ["f1" "f2" "f3" "f4" "f5" "f6" "f7" "f8" "f9" "f10" "f11" "f12"]
        ++ [null null null "end" null null null "[" "]" "grv" "pgup" null]
        ++ [null "home" null "del" "right" null "bspc" "ret" null null null null]
        ++ [null null null null "left" "pgdn" null null null null]
        ++ [null]
      )
    ];
    level2 = [
      src-layout
      (
        [null null null "brdn" "bru" null null null null "vold" "volu" null]
        ++ [null null null null "ins" null null "kp+" "up" "kp-" null null]
        ++ [null null "prnt" null null null "spc" "left" "down" "right" "ret" null]
        ++ [null null null null null null "mute" null null null]
        ++ [null]
      )
    ];
    level3 = [
      src-layout
      (
        [null null null null null null null "kp7" "kp8" "kp9" null "powr"]
        ++ [null null null null null null null "kp4" "kp5" "kp6" null null]
        ++ [null null null null null null null "kp1" "kp2" "kp3" null null]
        ++ [null null null null null null "kp0" "kp." "kprt" null]
        ++ [null]
      )
    ];
    level-mods = level1: level2: level3: {
      "spc" = "(layer-while-held ${level1})";
      "caps" = "(layer-while-held ${level2})";
      "tab" = "(layer-while-held ${level3})";
    };
    mods = {
      "a" = "lmet";
      "s" = "lalt";
      "d" = "lsft";
      "f" = "lctl";
      "j" = "rctl";
      "k" = "rsft";
      "l" = "ralt";
      ";" = "rmet";
    };
    withMods = lib.flip mergeTapHold mods;
  };
}
