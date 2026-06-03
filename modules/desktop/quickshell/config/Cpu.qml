pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    property var cpuTotal: 1
    property var cpuIdle: 1
    property var cpuCount: statView.text().split("\n").filter(line=>line.startsWith("cpu")).length-1
    FileView {
        id: statView
        property var cpuGlobal: this.text().split("\n")[0].replace(/ +/g, " ").split(" ").map(
            entry => parseInt(entry)||0
        )
        property var cpuTotalNow: this.cpuGlobal.reduce((a,b)=>a+b, 0)
        property var cpuIdleNow: this.cpuGlobal[4]+this.cpuGlobal[5]  // idle+iowait
        property var cpuTotalPrev: 0
        property var cpuIdlePrev: 0
        path: "/proc/stat"
        preload: true
        onLoaded: {
            cpuTotal = this.cpuTotalNow-this.cpuTotalPrev
            cpuIdle = this.cpuIdleNow-this.cpuIdlePrev
            this.cpuTotalPrev = this.cpuTotalNow
            this.cpuIdlePrev = this.cpuIdleNow
        }
    }
    property var load: parseFloat(loadavgView.text().split(" ")[0])
    FileView {
        id: loadavgView
        path: "/proc/loadavg"
        preload: true
    }
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            statView.reload();
            loadavgView.reload();
        }
    }
}
