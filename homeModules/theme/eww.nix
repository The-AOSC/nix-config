{
  inputs,
  config,
  lib,
  ...
}: let
  inherit (config.catppuccin) accent flavor;
  palette = (lib.importJSON "${config.catppuccin.sources.palette}/palette.json")."${flavor}".colors;
in {
  modules.eww.style = lib.mkBefore ''
    ${lib.concatMapAttrsStringSep "\n" (name: value: "\$${name}: ${value.hex};")
      palette}
    $accent: ${palette.${accent}.hex};
  '';
}
