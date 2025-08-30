{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    modules.powerctl.enable = lib.mkEnableOption "powerctl";
  };
  config = lib.mkIf config.modules.powerctl.enable {
    home.packages = [
      (let
        commands = [
          ["Suspend" "sync; systemctl suspend"]
          ["Hibernate" "sync; systemctl hibernate"]
          ["Hybrid-sleep" "sync; systemctl hybrid-sleep"]
          ["Log-out" "qtile cmd-obj -o cmd -f shutdown"]
          ["Shutdown" "sync; systemctl poweroff"]
          ["Reboot" "sync; systemctl reboot"]
        ];
      in
        pkgs.writeShellScriptBin "powerctl" ''
          set -e
          function print-help() {
            echo "$0" "[action]"
            echo Valid actions:
            ${lib.concatMapStringsSep "\n" (command: "echo ${lib.toLower (builtins.elemAt command 0)}\n") commands}
          }
          case "$#" in
            0)
              action="$(printf "${lib.concatMapStringsSep ''\n'' (command: builtins.elemAt command 0) commands}" | ${pkgs.wmenu}/bin/wmenu -i)"
              case "$action" in
                ${lib.concatMapStringsSep "\n" (command: ''
              ${builtins.elemAt command 0})
                ${builtins.elemAt command 1}
                ;;
            '')
            commands}
                *)
                  echo No matches for "$action"
                  ;;
              esac
              ;;
            1)
              case "$1" in
                --help | -h)
                  print-help
                  ;;
                ${lib.concatMapStringsSep "\n" (command: ''
              ${lib.toLower (builtins.elemAt command 0)})
                ${builtins.elemAt command 1}
                ;;
            '')
            commands}
                *)
                  echo unknown action: "$1"
                  print-help
                  ;;
              esac
              ;;
            *)
              print-help
              ;;
          esac
        '')
    ];
  };
}
