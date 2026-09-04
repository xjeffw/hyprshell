import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

BarSection {
    id: root

    required property var screen
    readonly property var hyprMonitor: Hyprland.monitorFor(screen)
    readonly property var toplevel: Hyprland.activeToplevel
    readonly property bool belongsHere: toplevel !== null && toplevel.monitor === hyprMonitor

    visible: belongsHere && toplevel.title.length > 0
    tooltipText: visible ? toplevel.title : ""

    Text {
        text: "▣"
        color: Theme.blue
        font.pixelSize: 14
    }

    Text {
        Layout.maximumWidth: 560
        text: root.belongsHere ? root.toplevel.title : ""
        color: Theme.text
        elide: Text.ElideRight
        font.family: Theme.fontFamily
        font.pixelSize: 13
        font.bold: true
    }
}
