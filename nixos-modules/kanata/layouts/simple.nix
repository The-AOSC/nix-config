{
  config,
  lib,
  ...
}: {
  kanata.layers = with config.lib.kanata; rec {
    simple = {"caps" = "esc";};
  };
}
