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
    property var currentWorkspace: (Hyprland.monitorFor(screen).activeWorkspace?.id || 1) - 1
    WorkspacesGroupWidget {
        currentWorkspace: root.currentWorkspace
        offset: 0
        step: dim2*dim3
        count: dim1
        switchAnimation: "fade"
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
                offset: Math.floor(root.currentWorkspace/5/5)*5*5
                step: dim3
                count: dim2
                switchAnimation: "slidevert -100%"
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
                        offset: Math.floor(root.currentWorkspace/5)*5
                        step: 1
                        count: dim3
                        switchAnimation: "slide"
                        WorkspaceWidget {
                            currentWorkspace: root.currentWorkspace
                            offset: root.currentWorkspace
                            step: 1
                        }
                    }
                }
            }
        }
    }
}
