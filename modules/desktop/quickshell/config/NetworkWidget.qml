import QtQuick
import QtQuick.Layouts
import Quickshell.Networking

import "theme.js" as Theme

RowLayout {
    spacing: 2
    property var widgetColor: NetworkProcess.defaultDevice?Theme.color.blue.hex:Theme.color.red.hex
    property var icon: (
        NetworkProcess.defaultDevice ?
        ({[DeviceType.Wifi]:"󰖩", [DeviceType.Wired]:""}[NetworkProcess.defaultDeviceType] || "") :
        ""
    )
    Text {
        verticalAlignment: Text.AlignVCenter
        text: NetworkProcess.defaultConnectionName || NetworkProcess.defaultDevice || "Disconnected"
        color: widgetColor
        font: Theme.font
    }
    Text {
        verticalAlignment: Text.AlignVCenter
        text: `(${NetworkProcess.defaultDevice || ""})`
        visible: !!(NetworkProcess.defaultDevice && NetworkProcess.defaultConnectionName)
        color: widgetColor
        font: Theme.font
    }
    Text {
        verticalAlignment: Text.AlignVCenter
        text: icon
        visible: !!icon
        color: widgetColor
        font: Theme.font
    }
}
