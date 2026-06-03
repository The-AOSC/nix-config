pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    property var memoryData: meminfoView.text().trim().split("\n").map(
        line => line.split(":")
    ).reduce(
        ((acc, val) => {
            if (val.length == 2) {
                acc[val[0]] = parseInt(val[1].trim().split(" ")[0]);
            }
            return acc;
        }),
        {}
    )
    FileView {
        id: meminfoView
        path: "/proc/meminfo"
        preload: true
    }
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: meminfoView.reload()
    }
}
