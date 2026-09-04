import QtQuick
import Quickshell.Services.Pipewire

BarSection {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool available: sink !== null && sink.audio !== null && sink.ready

    visible: available
    interactive: true
    tooltipText: available ? sink.description + " — click to mute; scroll to change volume" : ""

    Text {
        text: root.available && root.sink.audio.muted ? "MUTED" : "VOL"
        color: root.available && root.sink.audio.muted ? Theme.red : Theme.teal
        font.family: Theme.fontFamily
        font.pixelSize: 11
        font.bold: true
    }

    Text {
        text: root.available ? Math.round(root.sink.audio.volume * 100) + "%" : ""
        color: Theme.text
        font.family: Theme.monoFontFamily
        font.pixelSize: 12
        font.bold: true
    }

    onClicked: {
        if (root.available)
            root.sink.audio.muted = !root.sink.audio.muted;
    }

    onWheel: wheel => {
        if (!root.available)
            return;
        const step = wheel.angleDelta.y > 0 ? 0.05 : -0.05;
        root.sink.audio.volume = Math.max(0, Math.min(1.5, root.sink.audio.volume + step));
    }
}
