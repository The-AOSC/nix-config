import QtQuick
import QtQuick.Layouts

import "theme.js" as Theme

RowLayout {
    spacing: 2
    Text {
        verticalAlignment: Text.AlignVCenter
        text: `${Brightness.brightness}%`
        color: Theme.color.rosewater.hex
        font: Theme.font
    }
    Text {
        verticalAlignment: Text.AlignVCenter
        property var icons: ["", "", "", "", "", "", "", "", ""]
        text: icons[Math.min(Math.max(0, Math.floor(Brightness.brightness/100*icons.length)), icons.length-1)]
        color: Theme.color.rosewater.hex
        font: Theme.font
    }
}
