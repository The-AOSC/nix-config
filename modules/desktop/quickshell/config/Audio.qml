pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    property var sink: Pipewire.defaultAudioSink
    property var source: Pipewire.defaultAudioSource
    PwObjectTracker {
        objects: [
            sink,
            source,
        ]
    }
}
