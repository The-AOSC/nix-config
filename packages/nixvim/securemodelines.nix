{
  pkgs,
  lib,
  ...
}: {
  extraPlugins = [pkgs.vimPlugins.securemodelines];
  globals."secure_modelines_allowed_items" = lib.concatLists [
    ["textwidth" "tw"]
    ["softtabstop" "sts"]
    ["tabstop" "ts"]
    ["shiftwidth" "sw"]
    ["expandtab" "et" "noexpandtab" "noet"]
    ["filetype" "ft"]
    ["foldmethod" "fdm"]
    ["readonly" "ro" "noreadonly" "noro"]
    ["rightleft" "rl" "norightleft" "norl"]
    ["wrap" "nowrap"]
  ];
}
