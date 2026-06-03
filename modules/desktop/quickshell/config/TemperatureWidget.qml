import QtQuick
import QtQuick.Layouts

import "theme.js" as Theme

RowLayout {
    id: root
    property var temp: Temperature.temperatureData[0]?.temp || -1
    property var widgetColor: (
        root.temp<60 ? Theme.color.green.hex :
        root.temp<80 ? Theme.color.yellow.hex :
        root.temp<90 ? Theme.color.peach.hex :
        Theme.color.red.hex
    )
    visible: root.temp>0
    spacing: 2
    Text {
        verticalAlignment: Text.AlignVCenter
        text: `${root.temp}°C`
        color: root.widgetColor
        font: Theme.font
    }
    Text {
        verticalAlignment: Text.AlignVCenter
        property var icons: ["", "", "", "", ""]
        text: icons[Math.min(Math.max(0, Math.floor((root.temp-45)/55*icons.length)), icons.length-1)]
        color: root.widgetColor
        font: Theme.font
        id: tmp
    }
}
