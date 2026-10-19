import QtQuick
import QtQuick.Layouts

BarSection {
    id: root

    required property var screen
    // niri always keeps an empty workspace at the bottom of each output; only
    // show it while it is active. Named workspaces are permanent, so show them.
    readonly property var workspaces: Niri.workspacesOn(screen.name).filter(workspace => workspace.name !== null || workspace.active_window_id !== null || workspace.is_active)

    visible: workspaces.length > 0
    horizontalPadding: 3
    spacing: 1
    tooltipText: "Workspaces"

    Repeater {
        model: root.workspaces

        delegate: Rectangle {
            id: workspaceButton

            required property var modelData

            Layout.preferredWidth: Math.max(24, label.implicitWidth + 12)
            Layout.preferredHeight: Theme.controlHeight - 6
            radius: 5
            // Neutral white highlights to suit the translucent black niri bar.
            color: modelData.is_focused ? Qt.rgba(1, 1, 1, 0.3) : modelData.is_active || workspaceMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : "transparent"

            Text {
                id: label

                anchors.centerIn: parent
                text: workspaceButton.modelData.name ?? workspaceButton.modelData.idx
                color: workspaceButton.modelData.is_focused ? "white" : workspaceButton.modelData.is_urgent ? Theme.red : Theme.text
                font.family: Theme.monoFontFamily
                font.pixelSize: 13
                font.weight: Theme.monoBoldFontWeight
            }

            MouseArea {
                id: workspaceMouse

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Niri.focusWorkspace(workspaceButton.modelData.id)
            }
        }
    }
}
