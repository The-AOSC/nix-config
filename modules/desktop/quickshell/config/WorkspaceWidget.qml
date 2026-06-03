import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

import "theme.js" as Theme

Text {
    required property var currentWorkspace
    required property var offset
    required property var step
    property var workspaces: Hyprland.workspaces.values.filter(workspace => (offset <= workspace.id-1)&&(workspace.id-1 < offset+step))
    text: workspaces.some(workspace => workspace.toplevels.values.length > 0) ? "" : ""
    color: (
        workspaces.some(workspace => workspace.focused) ? Theme.color.mauve.hex :
        workspaces.some(workspace => workspace.active) ? Theme.color.blue.hex :
        workspaces.some(workspace => workspace.urgent) ? Theme.color.red.hex :
        Theme.color.text.hex
    )
    font: Theme.font
    MouseArea {
        anchors.fill: parent
        onClicked: Hyprland.dispatch(`
          function()
            hl.animation({
              bezier = "default",
              enabled = true,
              leaf = "workspaces",
              speed = 8.0,
              style = "${switchAnimation}",
            })
            hl.dispatch(hl.dsp.focus({workspace=${offset + currentWorkspace%step + 1}}))
          end
        `)
    }
}
