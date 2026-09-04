pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.Pipewire

ShellRoot {
    id: root

    SystemStats {
        id: systemStats
    }

    // PipeWire properties are lazy. Track the current sink once here so every
    // monitor can share the populated audio object.
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    Variants {
        model: Quickshell.screens

        delegate: Bar {
            stats: systemStats
        }
    }

    NotificationManager {}
}
