import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets

import "theme.js" as Theme

RowLayout {
    spacing: 2
    WrapperMouseArea {
        RowLayout {
            spacing: 2
            Text {
                verticalAlignment: Text.AlignVCenter
                text: `${Math.round(Audio.sink?.audio.volume*100)}%`
                visible: !!Audio.sink && !Audio.sink.audio.muted
                color: Theme.color.maroon.hex
                font: Theme.font
            }
            Text {
                verticalAlignment: Text.AlignVCenter
                text: Audio.sink?.audio.muted?"󰖁":"󰕾"
                visible: !!Audio.sink
                color: Theme.color.maroon.hex
                font: Theme.font
            }
        }
        onClicked: {
            if (Audio.sink?.audio) {
                Audio.sink.audio.muted = !Audio.sink.audio.muted;
            }
        }
    }
    WrapperMouseArea {
        RowLayout {
            spacing: 2
            Text {
                verticalAlignment: Text.AlignVCenter
                text: `${Math.round(Audio.source?.audio.volume*100)}%`
                visible: !!Audio.source && !Audio.source.audio.muted
                color: Theme.color.maroon.hex
                font: Theme.font
            }
            Text {
                verticalAlignment: Text.AlignVCenter
                text: Audio.source?.audio.muted?"":""
                visible: !!Audio.source
                color: Theme.color.maroon.hex
                font: Theme.font
            }
        }
        onClicked: {
            if (Audio.source?.audio) {
                Audio.source.audio.muted = !Audio.source.audio.muted;
            }
        }
    }
}
