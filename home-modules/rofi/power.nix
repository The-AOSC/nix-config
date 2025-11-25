{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.modules.rofi.enable {
    programs.rofi.modes = [
      {
        name = "power";
        path = let
          commands = [
            ["󰒲 Suspend" "sleep 1; sync; systemctl suspend"]
            ["󰋊 Hibernate" "sleep 1; sync; systemctl hibernate"]
            ["󰌾 Lock" "sleep 1; loginctl lock-session"]
            ["󰍁 Transparent lock" "sleep 1; hyprlock"]
            ["󰍃 Log-out" "uwsm stop"]
            ["󰐥 Shutdown" "sync; systemctl poweroff"]
            ["󰜉 Reboot" "sync; systemctl reboot"]
          ];
          script = pkgs.writeShellScript "rofi-power" ''
            set -e
            if [ "$#" -eq 0 ]; then
              printf '\0no-custom\x1ftrue\n'
              ${lib.concatMapStringsSep "\n" (command: ''
                printf "%s\n" "${builtins.elemAt command 0}"
              '')
              commands}
            else
              case "$1" in
                ${lib.concatMapStringsSep "\n" (command: ''
                "${builtins.elemAt command 0}")
                  ${pkgs.runtimeShell} -c "${builtins.elemAt command 1}" >/dev/null 2>&1 &
                  ;;
              '')
              commands}
                *)
                  exit 1
                  ;;
              esac
            fi
          '';
        in "${script}";
      }
    ];
  };
}
