{
  config,
  lib,
  ...
}: {
  modules.kanata.layers.mouse = with config.lib.kanata; rec {
    extra-conf = ''
      (defvirtualkeys
        vkey-mlft mlft
        vkey-mrgt mrgt
        vkey-mmid mmid)
    '';
    default = hold: {
      "j" = "(multi (on-press press-vkey vkey-mlft) (on-release release-vkey vkey-mlft))";
      "k" = "(multi (on-press press-vkey vkey-mrgt) (on-release release-vkey vkey-mrgt))";
      "i" = "(multi (on-press press-vkey vkey-mmid) (on-release release-vkey vkey-mmid))";
      "o" = "(layer-while-held ${hold})";
    };
    hold = {
      "j" = "(on-press press-vkey vkey-mlft)";
      "k" = "(on-press press-vkey vkey-mrgt)";
      "i" = "(on-press press-vkey vkey-mmid)";
    };
  };
}
