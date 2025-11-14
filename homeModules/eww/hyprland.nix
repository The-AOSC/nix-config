{
  config,
  pkgs,
  lib,
  ...
}: let
  hyprctl = "${config.wayland.windowManager.hyprland.finalPackage}/bin/hyprctl";
  hyprlisten = ''${pkgs.socat}/bin/socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do handle "$line"; done'';
  workspaces-listener = pkgs.writeShellScript "hyprland-workspaces-listener" ''
    set -e
    handle() {
      case $1 in
        "openwindow>>"* | \
        "closewindow>>"* | \
        "movewindow>>"*)
          ${hyprctl} workspaces -j | jq -c '{nonempty:map(select(.windows > 0).id)}'
          ;;
      esac
    }
    handle "openwindow>>" # generate initial value
    ${hyprlisten}
  '';
  workspace-state-listener = pkgs.writeShellScript "workspace-state-listener" ''
    set -e
    handle() {
      case $1 in
        "urgent>>"*)
          urgent="$(hyprctl clients -j | jq ".[]|select(.address == \"0x$(echo "$1" | cut -d '>' -f 3- | cut -d , -f 1)\").workspace.id")"
          if [ -z "$urgent" ]; then
            urgent=0
          fi
          if [ "$urgent" -eq "$active" ]; then
            urgent=0
          fi
          printf '{"active": %d, "urgent": %d}\n' "$active" "$urgent"
          ;;
        "workspacev2>>"*)
          active="$(echo "$1" | cut -d '>' -f 3- | cut -d , -f 1)"
          if [ "$urgent" -eq "$active" ]; then
            urgent=0
          fi
          printf '{"active": %d, "urgent": %d}\n' "$active" "$urgent"
          ;;
        "focusedmonv2>>"*)
          active="$(echo "$1" | cut -d '>' -f 3- | cut -d , -f 2)"
          if [ "$urgent" -eq "$active" ]; then
            urgent=0
          fi
          printf '{"active": %d, "urgent": %d}\n' "$active" "$urgent"
          ;;
      esac
    }
    urgent=0
    active="$(${hyprctl} activeworkspace -j | jq -c '.id')"
    printf '{"active": %d, "urgent": %d}\n' "$active" "$urgent"
    ${hyprlisten}
  '';
in {
  modules.eww.config = ''
    (deflisten workspaces :initial "{\"nonempty\":[]}"
      "${workspaces-listener}")
    (deflisten workspace-state :initial '{"active":0,"urgent":0}'
      "${workspace-state-listener}")
    (deflisten current-window :initial "[]"
      "${lib.getExe pkgs.hyprland-activewindow} _ | ${lib.getExe pkgs.gnused} --unbuffered -e 's/\\\\/\\\\\\\\/g'")
    (defwidget workspaces []
      (box :orientation "h"
           :space-evenly false
           :class "workspaces"
        ${let
      array_sizes = lib.map lib.toInt (lib.reverseList (lib.splitString ":" config.wayland.windowManager.hyprland.settings.plugin.mdw.array_sizes));
      generate = sizes: offset: let
        level = lib.length sizes;
        sub-count = lib.head sizes;
        sub-sizes = lib.tail sizes;
        sub-step = lib.fold builtins.mul 1 sub-sizes;
        generate-subelement = index: generate sub-sizes (sub-step * index + offset);
      in
        if level == 0
        then ''
          (workspace :id ${builtins.toString offset})
        ''
        else ''
          (workspace-group :level ${builtins.toString level}
                           :from ${builtins.toString offset}
                           :to ${builtins.toString (sub-step * sub-count + offset)}
            ${lib.concatMapStrings generate-subelement (lib.genList lib.id sub-count)})
        '';
    in
      generate array_sizes 1}))
  '';
}
