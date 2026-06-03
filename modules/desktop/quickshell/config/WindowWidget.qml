import QtQuick
import Quickshell.Hyprland

import "theme.js" as Theme

Text {
    required property var screen
    verticalAlignment: Text.AlignVCenter
    text: (Hyprland.monitorFor(screen).focused ? Hyprland.focusedWorkspace?.toplevels.values.find(toplevel => toplevel.activated)?.title : "") || ""
    textFormat: Text.PlainText
    elide: Text.ElideRight
    color: Theme.color.text.hex
    font: Theme.font
}
