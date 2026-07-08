{
  self,
  lib,
  ...
}: {
  lib.kanata.layouts.full = {config, ...}: {
    imports = [
      {
        layers = with self.lib.kanata.layers; {
          inherit home-row-mods;
        };
      }
    ];
    defaultLayer = config.layers.home-row-mods.name;
    extraConfig = "(defvirtualkeys pad-touch (switch ((layer ${config.layers.simple.name}) (layer ${config.layers.home-row-mods.name})) nop9 break))"; # glide intergration
    port = 7070; # glide intergration
    layers = {
      simple.binds = {
        "caps" = "esc";
        "j" = "(switch ((input virtual pad-touch)) mlft break () j break)";
        "k" = "(switch ((input virtual pad-touch)) mrgt break () k break)";
        "i" = "(switch ((input virtual pad-touch)) mmid break () i break)";
        "ralt" = "(layer-while-held ${config.layers.mode-select.name})";
      };
      simple-mouse.binds = {
        "caps" = "esc";
        "j" = "mlft";
        "k" = "mrgt";
        "i" = "mmid";
        "ralt" = "(layer-while-held ${config.layers.mode-select.name})";
      };
      home-row-mods.binds = {
        "j" = lib.mkForce "(tap-hold 200 250 (switch ((input virtual pad-touch)) mlft break () j break) rctl)";
        "k" = lib.mkForce "(tap-hold 200 250 (switch ((input virtual pad-touch)) mrgt break () k break) rsft)";
        "i" = lib.mkForce "(tap-hold 200 250 (switch ((input virtual pad-touch)) mmid break () i break) XX)";
        "ralt" = "(layer-while-held ${config.layers.mode-select.name})";
      };
      home-row-mods.subLayers.level1.binds = {
        "lsft" = "f19";
        "rsft" = "f24";
      };
      mode-select = {
        binds = {
          "h" = "(layer-switch ${config.layers.home-row-mods.name})";
          "s" = "(layer-switch ${config.layers.simple.name})";
          "m" = "(layer-switch ${config.layers.simple-mouse.name})";
          "___" = "XX";
        };
      };
    };
  };
}
