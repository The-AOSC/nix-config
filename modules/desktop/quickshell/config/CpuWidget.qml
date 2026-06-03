import QtQuick
import QtQuick.Layouts

import "theme.js" as Theme

RowLayout {
    spacing: 2
    property var widgetColor: (
        Cpu.load < Cpu.cpuCount/2 ? Theme.color.green.hex :
        Cpu.load < Cpu.cpuCount ? Theme.color.yellow.hex :
        Theme.color.red.hex
    )
    Text {
        verticalAlignment: Text.AlignVCenter
        text: `${(100-100*Cpu.cpuIdle/Cpu.cpuTotal).toFixed(0)}%`
        color: widgetColor
        font: Theme.font
    }
    Text {
        verticalAlignment: Text.AlignVCenter
        text: `(${Cpu.load.toFixed(2)})`
        color: widgetColor
        font: Theme.font
    }
    Text {
        verticalAlignment: Text.AlignVCenter
        text: ""
        color: widgetColor
        font: Theme.font
    }
}
