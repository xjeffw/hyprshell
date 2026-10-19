import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

BarSection {
    id: root

    required property var screen
    // Avoid touching the Hyprland singleton under niri; it would try to connect.
    readonly property var hyprMonitor: Niri.available ? null : Hyprland.monitorFor(screen)
    readonly property var toplevel: Niri.available ? Niri.focusedWindowOn(screen.name) : Hyprland.activeToplevel
    readonly property bool belongsHere: toplevel !== null && (Niri.available || toplevel.monitor === hyprMonitor)
    readonly property string title: belongsHere ? toplevel.title ?? "" : ""
    readonly property int titleMaximumWidth: Math.max(1000, Math.round(screen.width * 0.5))

    visible: title.length > 0
    Layout.maximumWidth: titleMaximumWidth + horizontalPadding * 2
    tooltipText: title

    Text {
        text: "▣"
        color: Theme.blue
        font.pixelSize: 14
    }

    Text {
        Layout.maximumWidth: root.titleMaximumWidth
        text: root.title
        color: Theme.text
        elide: Text.ElideRight
        font.family: Theme.fontFamily
        font.pixelSize: 13
        font.bold: true
    }
}
