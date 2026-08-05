pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Singleton {
    id: root
    property var gridWorkspaceMap: {}
    property var workspaceGridMap: []
    Process {
        id: process
        command: ["hyprctl", "-j", "get_grid_workspaces_map"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: () => {
                root.gridWorkspaceMap = JSON.parse(this.text);
                let transpose_map = (map, acc) => {
                    if (typeof(map)=="number") {
                        return {[map]: acc};
                    } else {
                        return Object.assign({}, ...(Object.entries(map).map(v => transpose_map(v[1], [...acc, v[0]]))));
                    }
                }
                root.workspaceGridMap = transpose_map(root.gridWorkspaceMap, []);
            }
        }
    }
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name == "hyprtaskingworkspacerearange") {
                process.running = true;
            }
        }
    }
}
