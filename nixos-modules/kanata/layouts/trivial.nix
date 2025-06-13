{
  config,
  lib,
  ...
}: {
  kanata.layers = with config.lib.kanata; rec {
    noDefault = {"___" = "XX";};
    passthroughKeys = keys: lib.listToAttrs (lib.map (key: lib.nameValuePair key key) keys);
    withNoDefault = mergeLayers noDefault;
  };
}
