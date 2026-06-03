pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property var brightness: 100
    Process {
        id: brightnessProc
        command: ["brightnessctl", "-m"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: () => {
                root.brightness = parseInt(this.text.split(",")[3])
            }
        }
    }
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: brightnessProc.running = true
    }
}
