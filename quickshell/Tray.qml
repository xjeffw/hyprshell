import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import Quickshell.Widgets

BarSection {
    id: root

    required property var hostWindow
    readonly property var items: SystemTray.items.values

    visible: items.length > 0
    horizontalPadding: 4
    spacing: 1
    tooltipText: "System tray"

    Repeater {
        model: SystemTray.items

        delegate: Rectangle {
            id: trayButton

            required property var modelData

            Layout.preferredWidth: 26
            Layout.preferredHeight: Theme.controlHeight - 4
            radius: 5
            color: trayMouse.containsMouse ? Theme.surface1 : "transparent"

            IconImage {
                anchors.centerIn: parent
                width: 18
                height: 18
                source: trayButton.modelData.icon
            }

            MouseArea {
                id: trayMouse

                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: mouse => {
                    const item = trayButton.modelData;
                    if (mouse.button === Qt.MiddleButton) {
                        item.secondaryActivate();
                    } else if (mouse.button === Qt.RightButton || item.onlyMenu) {
                        const point = root.hostWindow.itemPosition(trayButton);
                        item.display(root.hostWindow, point.x, point.y + trayButton.height);
                    } else {
                        item.activate();
                    }
                }

                onWheel: wheel => trayButton.modelData.scroll(wheel.angleDelta.y, false)
            }
        }
    }
}
