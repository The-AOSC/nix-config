import QtQuick
import QtQuick.Layouts
import Quickshell

import "theme.js" as Theme

Scope {
    readonly property real borderRadius: 12.5
    readonly property real pad: 5
    readonly property real spacing: 5
    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: root
            required property var modelData
            screen: modelData
            anchors {
                top: true
                left: true
                right: true
            }
            implicitHeight: 30
            color: "transparent"
            Item {
                anchors {
                    fill: parent
                    topMargin: 5
                    leftMargin: 15
                    rightMargin: 15
                }
                Rectangle {
                    id: left
                    radius: borderRadius
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    implicitWidth: barLeft.implicitWidth+pad*2
                    color: Theme.color.surface0.hex
                    BarLeft {
                        id: barLeft
                        anchors.fill: parent
                        anchors.leftMargin: pad
                        anchors.rightMargin: pad
                        screen: root.screen
                    }
                }
                Rectangle {
                    id: middle
                    radius: borderRadius
                    visible: barMiddle.implicitWidth > 0
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.right: right.left
                    anchors.left: left.right
                    anchors.leftMargin: Math.max(
                        Math.min(
                            parent.width/2-left.width-this.implicitWidth/2,  // centered
                            parent.width-left.width-this.implicitWidth-right.width-spacing,  // right aligned
                        ),
                        spacing,  // left aligned
                    )
                    anchors.rightMargin: Math.max(
                        Math.min(
                            parent.width/2-right.width-this.implicitWidth/2,  // centered
                            parent.width-right.width-this.implicitWidth-left.width-spacing,  // left aligned
                        ),
                        spacing,  // right aligned
                    )
                    implicitWidth: barMiddle.implicitWidth+pad*2
                    color: Theme.color.surface0.hex
                    BarMiddle {
                        id: barMiddle
                        width: parent.width
                        anchors.fill: parent
                        anchors.leftMargin: pad
                        anchors.rightMargin: pad
                        screen: root.screen
                    }
                }
                Rectangle {
                    id: right
                    radius: borderRadius
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    implicitWidth: barRight.implicitWidth+pad*2
                    color: Theme.color.surface0.hex
                    BarRight {
                        id: barRight
                        anchors.fill: parent
                        anchors.leftMargin: pad
                        anchors.rightMargin: pad
                    }
                }
            }
        }
    }
}
