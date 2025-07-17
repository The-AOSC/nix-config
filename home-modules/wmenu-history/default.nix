{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    modules.wmenu-history.enable = lib.mkEnableOption "wmenu-history";
  };
  config = lib.mkIf config.modules.wmenu-history.enable {
    home.packages = [
      (pkgs.writeShellScriptBin "wmenu-history" ''
        DATA_FILE="$HOME/.local/share/wmenu-history.dat"
        HISTORY_LEN=10

        [ -e "$DATA_FILE" ] || :>"$DATA_FILE"

        name="$(${pkgs.dmenu}/bin/dmenu_path | ${pkgs.moreutils}/bin/combine - not "$DATA_FILE" | cat "$DATA_FILE" - | ${pkgs.wmenu}/bin/wmenu)"

        if [ -n "$name" ]; then
            (
            echo "$name";
            echo "$name" | ${pkgs.moreutils}/bin/combine "$DATA_FILE" not -
            ) | head -n "$HISTORY_LEN" | ${pkgs.moreutils}/bin/sponge "$DATA_FILE"
            exec $name
        fi
      '')
    ];
    home.persistence."/persist" = {
      files = [
        ".local/share/wmenu-history.dat"
      ];
    };
  };
}
