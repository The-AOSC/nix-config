{
  self,
  lib,
  ...
}: {
  lib.kanata.layouts.full = {config, ...}: let
    layer-switch = layer: "(multi (layer-switch ${layer}) ${config.layers.taipo.unlock-mods-action} ${config.layers.gaming.unlock-mods-action})";
  in {
    imports = [
      {
        layers = with self.lib.kanata.layers; {
          taipo = taipo {
            left = ["r" "e" "w" "q" "f" "d" "s" "a" "v" "g" "c"];
            right = ["u" "i" "o" "p" "j" "k" "l" ";" "n" "h" "m"];
          };
          gaming = taipo {
            right = ["u" "i" "o" "p" "j" "k" "l" ";" "n" "h" "m"];
          };
          inherit home-row-mods;
        };
      }
    ];
    defaultLayer = config.layers.taipo.name;
    layers = {
      simple.binds = {
        "caps" = "esc";
        "ralt" = "(layer-while-held ${config.layers.mode-select.name})";
      };
      home-row-mods.binds = {
        "ralt" = "(layer-while-held ${config.layers.mode-select.name})";
      };
      home-row-mods.subLayers.level1.binds = {
        "lsft" = "f19";
        "rsft" = "f24";
      };
      taipo.binds = {
        "," = "mlft";
        "." = "mrgt";
        "/" = "mmid";
        "x" = "mlft";
        "z" = "mrgt";
        "lsft" = "mmid";
        "ralt" = "(layer-while-held ${config.layers.mode-select.name})";
        "___" = "XX";
      };
      gaming.binds = {
        "caps" = "esc";
        "," = "mlft";
        "." = "mrgt";
        "/" = "mmid";
        "ralt" = "(layer-while-held ${config.layers.mode-select.name})";
      };
      mode-select = {
        binds = {
          "h" = layer-switch config.layers.home-row-mods.name;
          "s" = layer-switch config.layers.simple.name;
          "m" = layer-switch config.layers.gaming.name;
          "t" = layer-switch config.layers.taipo.name;
          "y" = layer-switch config.layers.taipo.name;
          "p" = layer-switch config.layers.taipo.name;
          "___" = "XX";
        };
      };
    };
  };
}
