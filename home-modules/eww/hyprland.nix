{
  config,
  pkgs,
  lib,
  ...
}: let
  # hyprctl clients -j | jq '.[]|select(.address == "0x2706d5c0").workspace.id' # activewindowv2>>2706d5c0 # 15
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
  active-workspace-listener = pkgs.writeShellScript "active-workspace-listener" ''
    set -e
    handle() {
      case $1 in
        "workspacev2>>"*)
          echo "$1" | cut -d '>' -f 3- | cut -d , -f 1
          ;;
        "focusedmonv2>>"*)
          echo "$1" | cut -d '>' -f 3- | cut -d , -f 2
          ;;
      esac
    }
    ${hyprctl} activeworkspace -j | jq -c '.id? // 0'
    ${hyprlisten}
  '';
  current-window-listener = pkgs.writeShellScript "hyprland-current-window-listener" ''
    set -e
    handle() {
      case $1 in
        "activewindow>>"*)
          echo "$1" | cut -d '>' -f 3- | cut -d , -f 2 | ${pkgs.gnused}/bin/sed -e 's/\\/\\\\/g'
          ;;
      esac
    }
    ${hyprctl} activewindow -j | jq -cr '.title? // ""'
    ${hyprlisten}
  '';
in {
  modules.eww.config = ''
    (deflisten workspaces :initial "{\"nonempty\":[]}"
      "${workspaces-listener}")
    (deflisten activeworkspace :initial "0"
      "${active-workspace-listener}")
    (deflisten current-window :initial ""
      "${current-window-listener}")
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
