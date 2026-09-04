import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

BarSection {
    id: root

    required property var screen
    readonly property var hyprMonitor: Hyprland.monitorFor(screen)
    readonly property var toplevel: Hyprland.activeToplevel
    readonly property bool belongsHere: toplevel !== null && toplevel.monitor === hyprMonitor
    readonly property int titleMaximumWidth: Math.max(1000, Math.round(screen.width * 0.5))

    visible: belongsHere && toplevel.title.length > 0
    Layout.maximumWidth: titleMaximumWidth + horizontalPadding * 2
    tooltipText: visible ? toplevel.title : ""

    Text {
        text: "▣"
        color: Theme.blue
        font.pixelSize: 14
    }

    Text {
        Layout.maximumWidth: root.titleMaximumWidth
        text: root.belongsHere ? root.toplevel.title : ""
        color: Theme.text
        elide: Text.ElideRight
        font.family: Theme.fontFamily
        font.pixelSize: 13
        font.bold: true
    }
}
