pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property var thermalZones: []
    Process {
        id: refreshThermalZonesProc
        command: ["sh", "-c", `cd /sys/class/thermal; ls -1`]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.thermalZones = this.text.trim().split("\n").filter(name => name.startsWith("thermal_zone"))
        }
    }
    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: refreshThermalZonesProc.running = true
    }
    property var temperatureData: variants.instances.map(scope => scope.temperatureData)
    Variants {
        id: variants
        model: root.thermalZones
        Scope {
            id: scope
            required property var modelData
            property var dir: `/sys/class/thermal/${modelData}`
            property var temperatureData: ({
                name: modelData,
                temp: parseInt(thermalStatus.text())/1000,
            })
            FileView {
                id: thermalStatus
                path: `${dir}/temp`
                preload: true
            }
            Timer {
                interval: 2000
                running: true
                repeat: true
                onTriggered: thermalStatus.reload()
            }
        }
    }
}
