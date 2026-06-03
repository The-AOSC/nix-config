import QtQuick
import QtQuick.Layouts

import "theme.js" as Theme

RowLayout {
    spacing: 2
    property var memTotal: Memory.memoryData.MemTotal
    property var memFree: Memory.memoryData.MemAvailable
    property var swapTotal: Memory.memoryData.SwapTotal
    property var swapFree: Memory.memoryData.SwapFree
    property var widgetColor: (
        (memFree+swapFree)/(memTotal+swapTotal)<0.2 ? Theme.color.red.hex : Theme.color.mauve.hex
    )
    Text {
        verticalAlignment: Text.AlignVCenter
        text: `${((memTotal-memFree)/1024/1024).toFixed(1)}G`
        color: widgetColor
        font: Theme.font
    }
    Text {
        verticalAlignment: Text.AlignVCenter
        text: `${((swapTotal-swapFree)/1024/1024).toFixed(1)}G`
        color: widgetColor
        font: Theme.font
    }
    Text {
        verticalAlignment: Text.AlignVCenter
        text: ""
        color: widgetColor
        font: Theme.font
    }
}
