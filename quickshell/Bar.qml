import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    required property var modelData
    required property var mediaManager
    required property var stats

    screen: modelData
    // The Rectangle below draws the background; painting it here too would
    // double up a translucent color.
    color: "transparent"
    implicitHeight: Theme.barHeight
    exclusiveZone: Theme.barHeight
    // Ask niri to blur the wallpaper behind the translucent bar.
    BackgroundEffect.blurRegion: Niri.available && !Config.transparentBar ? blurRegion : null

    anchors {
        top: true
        left: true
        right: true
    }

    Region {
        id: blurRegion

        item: background
    }

    Rectangle {
        id: background

        anchors.fill: parent
        visible: !Config.transparentBar
        color: Theme.barBackground

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

        Loader {
            sourceComponent: Niri.available ? niriWorkspaces : hyprlandWorkspaces

            Component {
                id: niriWorkspaces

                NiriWorkspaces {
                    screen: root.screen
                }
            }

            Component {
                id: hyprlandWorkspaces

                Workspaces {
                    screen: root.screen
                }
            }
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

        Battery {
            stats: root.stats
        }

        Audio {}

        Clock {}
    }
}
