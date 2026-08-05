import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

import "theme.js" as Theme

RowLayout {
    id: root
    spacing: 5
    default required property var child
    required property var currentWorkspace
    required property var activePos
    required property var workspaces
    required property var count
    required property var axis
    property bool reverse: false
    Repeater {
        model: root.count
        RowLayout {
            id: row
            required property var modelData
            WorkspaceWidget {
                currentWorkspace: root.currentWorkspace
                visible: (reverse?root.count-row.modelData-1:row.modelData) != activePos
                workspaces: root.workspaces[reverse?root.count-row.modelData-1:row.modelData] ?? {}
                MouseArea {
                    anchors.fill: parent
                    onClicked: Hyprland.dispatch(`
                      function()
                        local layer,x,y = hl.plugin.hyprtasking.workspace_id_to_pos((hl.get_active_workspace() or {id=-1}).id)
                        ${axis} = ${reverse?root.count-row.modelData-1:row.modelData}
                        local warp = hl.get_config("cursor.warp_on_change_workspace")
                        hl.config({cursor={warp_on_change_workspace=0}})
                        hl.plugin.hyprtasking.setlayer(layer)
                        hl.plugin.hyprtasking.move_id(hl.plugin.hyprtasking.pos_to_workspace_id(layer,x,y))
                        hl.config({cursor={warp_on_change_workspace=warp}})
                      end
                    `);
                }
            }
            LayoutItemProxy {
                target: child
                visible: (reverse?root.count-row.modelData-1:row.modelData) == activePos
            }
        }
    }
}
