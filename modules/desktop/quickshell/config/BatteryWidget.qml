import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

import "theme.js" as Theme

RowLayout {
    Repeater {
        model: ScriptModel {
            values: Battery.batteriesData
            objectProp: "name"
        }
        WrapperMouseArea {
            id: model
            required property var modelData
            hoverEnabled: true
            RowLayout {
                spacing: 2
                id: battery
                property var widgetColor: (
                    modelData.health<0.5 ? Theme.color.red.hex :
                    modelData.discharging ? (
                        modelData.capacity<0.15 ? Theme.color.red.hex :
                        Theme.color.yellow.hex
                    ) :
                    Theme.color.green.hex
                )
                Text {
                    verticalAlignment: Text.AlignVCenter
                    text: model.modelData.charging?"^":"v"
                    visible: model.modelData.charging || model.modelData.discharging
                    color: battery.widgetColor
                    font: Theme.font
                }
                Text {
                    verticalAlignment: Text.AlignVCenter
                    text: `${(model.modelData.capacity*100).toFixed(1)}%`
                    color: battery.widgetColor
                    font: Theme.font
                }
                Text {
                    verticalAlignment: Text.AlignVCenter
                    property var icons: ["", "", "", "", ""]
                    text: icons[Math.min(Math.max(0, Math.floor(model.modelData.capacity*icons.length)), icons.length-1)] || ""
                    color: battery.widgetColor
                    font: Theme.font
                }
                Text {
                    verticalAlignment: Text.AlignVCenter
                    text: `${Math.floor(model.modelData.remaining/60/60)}:${(Math.floor(model.modelData.remaining/60)%60).toString().padStart(2, "0")}`
                    visible: (model.modelData.charging || model.modelData.discharging) && (model.modelData.remaining > 0)
                    color: battery.widgetColor
                    font: Theme.font
                }
                Text {
                    verticalAlignment: Text.AlignVCenter
                    text: `${model.modelData.name}`
                    visible: model.containsMouse
                    color: battery.widgetColor
                    font: Theme.font
                }
                Text {
                    verticalAlignment: Text.AlignVCenter
                    text: `${(model.modelData.health*100).toFixed(1)}%`
                    visible: model.containsMouse
                    color: battery.widgetColor
                    font: Theme.font
                }
                Text {
                    verticalAlignment: Text.AlignVCenter
                    text: `(${model.modelData.charge[0]}/${model.modelData.charge[1]}/${model.modelData.charge[2]}mAh)`
                    visible: model.containsMouse
                    color: battery.widgetColor
                    font: Theme.font
                }
            }
        }
    }
}
