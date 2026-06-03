pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property string time
    Process {
        id: dateProc
        command: ["date", "+%y/%m.%d(%u) %H:%M:%S"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.time = this.text.trim()
        }
    }
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: dateProc.running = true
    }
}
