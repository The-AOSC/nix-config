{
  config,
  lib,
  ...
}: {
  modules.kanata.layers = with config.lib.kanata; rec {
    simple = {"caps" = "esc";};
  };
}
