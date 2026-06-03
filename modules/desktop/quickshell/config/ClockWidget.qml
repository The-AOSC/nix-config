import QtQuick
import QtQuick.Layouts

import "theme.js" as Theme

RowLayout {
    spacing: 2
    Repeater {
        model: Time.time.split(" ")
        Text {
            required property var modelData
            verticalAlignment: Text.AlignVCenter
            text: modelData
            color: Theme.color.sapphire.hex
            font: Theme.font
        }
    }
}
