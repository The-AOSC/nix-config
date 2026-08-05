import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

import "theme.js" as Theme

Text {
    id: root
    function unfoldWorkspaces(workspaces) {
        if (typeof(workspaces)=="number") {
            return [workspaces];
        } else {
            return [].concat(...Object.entries(workspaces).map(v => unfoldWorkspaces(v[1])));
        }
    }
    required property var currentWorkspace
    required property var workspaces
    property var hyprlandWorkspaces: Hyprland.workspaces.values.filter(workspace => unfoldWorkspaces(workspaces).includes(workspace.id))
    text: hyprlandWorkspaces.some(workspace => workspace.toplevels.values.length > 0) ? "" : ""
    color: (
        hyprlandWorkspaces.some(workspace => workspace.focused) ? Theme.color.mauve.hex :
        hyprlandWorkspaces.some(workspace => workspace.active) ? Theme.color.blue.hex :
        hyprlandWorkspaces.some(workspace => workspace.urgent) ? Theme.color.red.hex :
        Theme.color.text.hex
    )
    font: Theme.font
}
