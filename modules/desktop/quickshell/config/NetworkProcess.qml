pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking

Singleton {
    id: root
    property var routes
    property var devicesStatus
    property var defaultRoute: routes?.find(route => route.dst == "default")
    property var defaultDevice: defaultRoute?.dev
    property var defaultDeviceType: Networking.devices.values.find(device => device.name == defaultDevice)?.type
    property var defaultDeviceStatus: devicesStatus?.find(status => status[0] == defaultDevice)
    property var defaultConnectionName: defaultDeviceStatus?defaultDeviceStatus[3]:undefined
    Process {
        id: ipRouteProc
        command: ["ip", "-j", "route"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: () => {
                root.routes = JSON.parse(this.text)
            }
        }
    }
    Process {
        id: nmcliDeviceStatus
        command: ["nmcli", "-t", "device", "status"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: () => {
                root.devicesStatus = this.text.split("\n").map(line => line.split(":"))
            }
        }
    }
    Process {
        id: ipMonitorProc
        command: ["ip", "monitor", "route"];
        running: true
        stdout: SplitParser {
            onRead: data => {
                ipRouteProc.running = true
                nmcliDeviceStatus.running = true
            }
        }
    }
    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: () => {
            ipRouteProc.running = true
            nmcliDeviceStatus.running = true
        }
    }
}
