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

    // One dot per window column beside the column niri focuses on the workspace.
    component ColumnDots: Row {
        id: dots

        property int count: 0
        property color color: Theme.text

        visible: count > 0
        opacity: 0.8
        spacing: 6

        Repeater {
            model: dots.count

            delegate: Rectangle {
                width: 4
                height: 4
                radius: 2
                color: dots.color
            }
        }
    }

    Repeater {
        model: root.workspaces

        delegate: Rectangle {
            id: workspaceButton

            required property var modelData
            readonly property var columns: Niri.columnsAround(modelData)

            Layout.preferredWidth: Math.max(24, content.implicitWidth + 16)
            Layout.preferredHeight: Theme.controlHeight - 6
            radius: 5
            // Neutral white highlights to suit the translucent black niri bar.
            color: modelData.is_focused ? Qt.rgba(1, 1, 1, 0.3) : modelData.is_active || workspaceMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : "transparent"

            Row {
                id: content

                anchors.centerIn: parent
                spacing: 6

                ColumnDots {
                    anchors.verticalCenter: parent.verticalCenter
                    count: workspaceButton.columns?.left ?? 0
                    color: label.color
                }

                Text {
                    id: label

                    anchors.verticalCenter: parent.verticalCenter
                    text: workspaceButton.modelData.name ?? workspaceButton.modelData.idx
                    color: workspaceButton.modelData.is_focused ? "white" : workspaceButton.modelData.is_urgent ? Theme.red : Theme.text
                    font.family: Theme.monoFontFamily
                    font.pixelSize: 13
                    font.weight: Theme.monoBoldFontWeight
                }

                ColumnDots {
                    anchors.verticalCenter: parent.verticalCenter
                    count: workspaceButton.columns?.right ?? 0
                    color: label.color
                }
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
