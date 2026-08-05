import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

import "theme.js" as Theme

RowLayout {
    id: root
    property var margins: 2
    property var borderRadius: 12.5
    property var pad: 5
    property var dim1: 5
    property var dim2: 5
    property var dim3: 5
    required property var screen
    property var currentWorkspace: Hyprland.monitorFor(screen).activeWorkspace?.id || 0
    property var activePos: Workspaces.workspaceGridMap[currentWorkspace] ?? [0, 0, 0]
    WorkspacesGroupWidget {
        currentWorkspace: root.currentWorkspace
        activePos: root.activePos[0]
        workspaces: Workspaces.gridWorkspaceMap ?? {}
        count: dim1
        axis: "layer"
        Rectangle {
            radius: root.borderRadius
            Layout.fillHeight: true
            Layout.leftMargin: root.margins
            Layout.rightMargin: root.margins
            color: Theme.color.surface1.hex
            implicitWidth: rect1.implicitWidth + root.pad*2
            implicitHeight: rect1.implicitHeight
            WorkspacesGroupWidget {
                id: rect1
                anchors.fill: parent
                anchors.leftMargin: root.pad
                anchors.rightMargin: root.pad
                currentWorkspace: root.currentWorkspace
                activePos: root.activePos[1]
                workspaces: (Workspaces.gridWorkspaceMap ?? {})[root.activePos[0]] ?? {}
                count: dim2
                axis: "y"
                reverse: true
                Rectangle {
                    radius: root.borderRadius
                    Layout.fillHeight: true
                    Layout.leftMargin: root.margins
                    Layout.rightMargin: root.margins
                    color: Theme.color.surface2.hex
                    implicitWidth: rect2.implicitWidth + root.pad*2
                    implicitHeight: rect2.implicitHeight
                    WorkspacesGroupWidget {
                        id: rect2
                        anchors.fill: parent
                        anchors.leftMargin: root.pad
                        anchors.rightMargin: root.pad
                        currentWorkspace: root.currentWorkspace
                        activePos: root.activePos[2]
                        workspaces: ((Workspaces.gridWorkspaceMap ?? {})[root.activePos[0]] ?? {})[root.activePos[1]] ?? {}
                        count: dim3
                        axis: "x"
                        WorkspaceWidget {
                            currentWorkspace: root.currentWorkspace
                            workspaces: (((Workspaces.gridWorkspaceMap ?? {})[root.activePos[0]] ?? {})[root.activePos[1]] ?? {})[root.activePos[2]] ?? {}
                        }
                    }
                }
            }
        }
    }
}
