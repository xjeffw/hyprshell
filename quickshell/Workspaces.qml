import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

RowLayout {
    id: root

    required property var screen
    readonly property var hyprMonitor: Hyprland.monitorFor(screen)
    readonly property var workspaceValues: Hyprland.workspaces.values

    spacing: 4

    function groupVisible(group) {
        const values = root.workspaceValues;
        for (let i = 0; i < values.length; i++) {
            const workspace = values[i];
            if (workspace.id > 0 && Math.floor((workspace.id - 1) / 10) === group && workspace.monitor === root.hyprMonitor) {
                return true;
            }
        }
        return false;
    }

    Repeater {
        model: 2

        delegate: BarSection {
            id: workspaceGroup

            required property int index
            readonly property int group: index

            visible: root.groupVisible(group)
            horizontalPadding: 3
            spacing: 1
            tooltipText: group === 0 ? "Workspaces 1–10" : "Workspaces 11–20"

            Repeater {
                model: Hyprland.workspaces

                delegate: Rectangle {
                    id: workspaceButton

                    required property var modelData
                    readonly property bool onThisMonitor: modelData.monitor === root.hyprMonitor
                    readonly property bool inThisGroup: modelData.id > 0 && Math.floor((modelData.id - 1) / 10) === workspaceGroup.group

                    visible: onThisMonitor && inThisGroup
                    Layout.preferredWidth: visible ? 24 : 0
                    Layout.preferredHeight: Theme.controlHeight - 6
                    radius: 5
                    color: modelData.focused ? Theme.green : modelData.active ? Theme.surface1 : workspaceMouse.containsMouse ? Theme.surface1 : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: modelData.id % 10
                        color: modelData.focused ? Theme.base : modelData.urgent ? Theme.red : modelData.active ? Theme.green : Theme.text
                        font.family: Theme.monoFontFamily
                        font.pixelSize: 13
                        font.bold: true
                    }

                    MouseArea {
                        id: workspaceMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: workspaceButton.modelData.activate()
                    }
                }
            }
        }
    }
}
