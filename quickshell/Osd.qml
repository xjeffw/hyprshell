pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Wayland

// Volume and brightness displays modeled on avizo: an icon over a row of
// level blocks, shown on every screen. Volume keys go through the "volume"
// IPC target, which changes the volume and shows the display even when the
// level is already at its limit. Scripts that change a monitor's brightness
// report the new level through the "brightness" target.
Scope {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool sinkAvailable: sink !== null && sink.audio !== null && sink.ready
    // Whole percentages, like pamixer's.
    readonly property int volume: sinkAvailable ? Math.round(sink.audio.volume * 100) : 0
    readonly property bool muted: sinkAvailable && sink.audio.muted
    // The monitor whose brightness last changed, and its level.
    property string monitor: ""
    property int brightness: 0
    // What the display shows: "volume" or "brightness".
    property string kind: "volume"
    readonly property int percent: kind === "volume" ? volume : brightness
    readonly property string title: kind === "brightness" ? monitor : ""
    // For the icon, the title, and the filled blocks.
    readonly property color foreground: Theme.subtext0
    property bool shown: false

    function show(newKind) {
        kind = newKind;
        shown = true;
        hideTimer.restart();
    }

    // Like pamixer without --allow-boost, raising stops at 100%, but leaves
    // a volume boosted past that (e.g. by scrolling on the bar) alone.
    function changeVolume(step) {
        if (!sinkAvailable)
            return;
        const target = step > 0 ? Math.max(volume, Math.min(100, volume + step)) : Math.max(0, volume + step);
        sink.audio.volume = target / 100;
        show("volume");
    }

    function toggleMute() {
        if (!sinkAvailable)
            return;
        sink.audio.muted = !sink.audio.muted;
        show("volume");
    }

    function showBrightness(name, level) {
        monitor = name;
        brightness = level;
        show("brightness");
    }

    Timer {
        id: hideTimer

        // How long avizo was configured to show for.
        interval: 1250
        repeat: false
        onTriggered: root.shown = false
    }

    IpcHandler {
        target: "volume"

        function up(): void {
            root.changeVolume(5);
        }

        function down(): void {
            root.changeVolume(-5);
        }

        function toggleMute(): void {
            root.toggleMute();
        }
    }

    IpcHandler {
        target: "brightness"

        // Returns true so callers can tell it was shown: `ipc call` also
        // exits successfully when the target or function doesn't exist.
        function changed(monitor: string, percent: int): bool {
            root.showBrightness(monitor, percent);
            return true;
        }
    }

    Variants {
        model: Quickshell.screens

        delegate: CardPanel {
            required property var modelData

            screen: modelData
            shown: root.shown
            visible: shown || fade > 0
            // avizo's default size.
            cardWidth: 248
            cardHeight: 232
            // Placed like avizo: over fullscreen windows, centered across the
            // whole screen and 3/4 of the way down it, ignoring the bar.
            WlrLayershell.layer: WlrLayer.Overlay
            // Matched by the layer-rule in the niri config.
            WlrLayershell.namespace: "hyprshell-osd"
            exclusionMode: ExclusionMode.Ignore
            // Clicks go through to what's underneath.
            mask: Region {}

            anchors {
                top: true
                left: true
            }

            margins {
                left: Math.round((modelData.width - cardWidth) * 0.5) - shadowMargin
                top: Math.round((modelData.height - cardHeight) * 0.75) - shadowMargin
            }

            Text {
                id: titleText

                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    topMargin: 22
                    leftMargin: 25
                    rightMargin: 25
                }
                visible: text.length > 0
                text: root.title
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                color: root.foreground
                font.family: Theme.fontFamily
                font.pixelSize: 15
                font.bold: true
            }

            VolumeIcon {
                anchors.centerIn: parent
                visible: root.kind === "volume"
                level: root.percent / 100
                muted: root.muted
                color: root.foreground
            }

            // Centered between the title and the blocks.
            BrightnessIcon {
                anchors.horizontalCenter: parent.horizontalCenter
                y: Math.round((titleText.y + titleText.height + levelBlocks.y - height) / 2)
                visible: root.kind === "brightness"
                level: root.percent / 100
                color: root.foreground
            }

            // 20 blocks along the bottom, inside avizo's 24px padding and the
            // border, each filled per 5% up to 100%.
            Row {
                id: levelBlocks

                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    margins: 25
                }
                spacing: 2

                Repeater {
                    model: 20

                    delegate: Rectangle {
                        required property int index

                        width: 8
                        height: 10
                        color: index < Math.floor(Math.min(root.percent, 100) / 5) ? root.foreground : Theme.surface2
                    }
                }
            }
        }
    }
}
