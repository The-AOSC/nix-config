{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    modules.nix-sh.enable = lib.mkEnableOption "nix-sh";
  };
  config = lib.mkIf config.modules.nix-sh.enable {
    home.packages = [
      (pkgs.writeShellScriptBin "nix-sh" ''
        case "$#" in
            0)
                ;;
            1)
                # shellcheck disable=SC2086
                #  intentional $1 space expansion
                exec nix-shell -p $1 --run "$(getent passwd "$(id -u)" | cut -d : -f 7)"
                ;;
            *)
                args="$1"
                shift
                # shellcheck disable=SC2086
                #  intentional $args space expansion
                exec nix-shell -p $args --run "$*"
                ;;
        esac
      '')
    ];
  };
}
