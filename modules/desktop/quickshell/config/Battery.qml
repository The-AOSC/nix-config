pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property var batteries: []
    Process {
        id: refreshBatteriesProc
        command: ["sh", "-c", `cd /sys/class/power_supply; ls -1`]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.batteries = this.text.trim().split("\n").filter(name => name.startsWith("BAT"))
        }
    }
    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: refreshBatteriesProc.running = true
    }
    property var batteriesData: variants.instances.map(scope => scope.batteryData)
    Variants {
        id: variants
        model: root.batteries
        Scope {
            id: scope
            required property var modelData
            property var dir: `/sys/class/power_supply/${modelData}`
            property var status: batStatus.text().trim()
            property var chargeNow: parseInt(batChargeNow.text())
            property var chargeFull: parseInt(batChargeFull.text())
            property var chargeFullDesign: parseInt(batChargeFullDesign.text())
            property var currentNow: parseInt(batCurrentNow.text())
            property var charging: scope.status.toLowerCase() == "charging"
            property var discharging: scope.status.toLowerCase() == "discharging"
            property var batteryData: ({
                name: modelData,
                charging: scope.charging,
                discharging: scope.discharging,
                remaining: scope.currentNow>0?((scope.charging?(scope.chargeFull-scope.chargeNow):scope.chargeNow)/scope.currentNow * 3600):-1,
                capacity: chargeNow / chargeFull,
                health: chargeFull / chargeFullDesign,
                charge: [chargeNow/1000, chargeFull/1000, chargeFullDesign/1000],
            })
            FileView {
                id: batStatus
                path: `${dir}/status`
                preload: true
            }
            FileView {
                id: batChargeNow
                path: `${dir}/charge_now`
                preload: true
            }
            FileView {
                id: batChargeFull
                path: `${dir}/charge_full`
                preload: true
            }
            FileView {
                id: batChargeFullDesign
                path: `${dir}/charge_full_design`
                preload: true
            }
            FileView {
                id: batCurrentNow
                path: `${dir}/current_now`
                preload: true
            }
            Timer {
                interval: 2000
                running: true
                repeat: true
                onTriggered: {
                    batStatus.reload();
                    batChargeNow.reload();
                    batChargeFull.reload();
                    batChargeFullDesign.reload();
                    batCurrentNow.reload();
                }
            }
        }
    }
}
