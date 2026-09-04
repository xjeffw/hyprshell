import QtQuick
import QtQuick.Layouts
import Quickshell

PanelWindow {
    id: root

    required property var modelData
    required property var mediaManager
    required property var stats

    screen: modelData
    color: "transparent"
    implicitHeight: Theme.barHeight
    exclusiveZone: Theme.barHeight

    anchors {
        top: true
        left: true
        right: true
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
