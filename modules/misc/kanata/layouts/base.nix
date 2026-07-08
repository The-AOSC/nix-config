{self, ...}: {
  lib.kanata.layouts.base = {config, ...}: {
    layers = {inherit (self.lib.kanata.layers) home-row-mods;};
    defaultLayer = config.layers.home-row-mods.name;
  };
}
