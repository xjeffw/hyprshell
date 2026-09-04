import QtQuick
import QtQuick.Layouts
import Quickshell

PanelWindow {
    id: root

    required property var modelData
    required property var mediaManager
    required property var stats

    screen: modelData
    color: Config.transparentBar ? "transparent" : Theme.mantle
    implicitHeight: Theme.barHeight
    exclusiveZone: Theme.barHeight

    anchors {
        top: true
        left: true
        right: true
    }

    Rectangle {
        anchors.fill: parent
        visible: !Config.transparentBar
        color: Theme.mantle

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 1
            color: Theme.surface1
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 5
        anchors.rightMargin: 5
        spacing: 4

        Workspaces {
            screen: root.screen
        }

        ActiveWindow {
            screen: root.screen
        }

        Item {
            Layout.fillWidth: true
        }

        Media {
            manager: root.mediaManager
        }

        Tray {
            hostWindow: root
        }

        SystemStatus {
            stats: root.stats
        }

        Audio {}

        Battery {}

        Clock {}
    }
}
