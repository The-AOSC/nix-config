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
    required property var offset
    required property var step
    required property var count
    required property var switchAnimation
    property var focusedIndex: Math.floor((currentWorkspace-offset)/step)%count
    Repeater {
        model: root.count
        RowLayout {
            id: row
            required property var modelData
            WorkspaceWidget {
                currentWorkspace: root.currentWorkspace
                visible: row.modelData != focusedIndex
                offset: root.offset + row.modelData*root.step
                step: root.step
            }
            LayoutItemProxy {
                target: child
                visible: row.modelData == focusedIndex
            }
        }
    }
}
