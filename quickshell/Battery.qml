import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell.Services.UPower

BarSection {
    id: root

    readonly property var battery: UPower.displayDevice
    readonly property bool available: battery !== null && battery.ready && battery.isPresent && battery.isLaptopBattery
    // UPower percentages are reported from 0 to 1.
    readonly property int percent: available ? Math.round(battery.percentage * 100) : 0
    readonly property bool charging: available && (battery.state === UPowerDeviceState.Charging || battery.state === UPowerDeviceState.PendingCharge)
    readonly property bool fullyCharged: available && battery.state === UPowerDeviceState.FullyCharged
    readonly property color levelColor: charging || fullyCharged ? Theme.green : percent <= 15 ? Theme.red : percent <= 30 ? Theme.yellow : Theme.green

    visible: available
    tooltipText: {
        if (!available)
            return "";

        const prefix = "Battery: " + percent + "%";

        if (fullyCharged)
            return prefix + " — fully charged";
        if (charging)
            return battery.timeToFull > 0 ? prefix + " — charging, " + formatDuration(battery.timeToFull) + " until full" : prefix + " — charging";
        if (battery.timeToEmpty > 0)
            return prefix + " — " + formatDuration(battery.timeToEmpty) + " remaining";

        return prefix + " — " + UPowerDeviceState.toString(battery.state).toLowerCase();
    }

    function formatDuration(seconds) {
        const totalMinutes = Math.round(seconds / 60);
        const hours = Math.floor(totalMinutes / 60);
        const minutes = totalMinutes % 60;
        return hours > 0 ? hours + "h " + minutes + "m" : minutes + "m";
    }

    Item {
        implicitWidth: 21
        implicitHeight: 12
        Layout.alignment: Qt.AlignVCenter

        Rectangle {
            id: shell

            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 19
            height: 12
            radius: 3
            color: Theme.surface1
            border.width: 1
            border.color: Theme.overlay0

            Rectangle {
                anchors.left: parent.left
                anchors.leftMargin: 2
                anchors.verticalCenter: parent.verticalCenter
                width: root.percent <= 0 ? 0 : Math.max(2, Math.round((shell.width - 4) * root.percent / 100))
                height: shell.height - 4
                radius: 1
                color: root.levelColor

                Behavior on width {
                    NumberAnimation {
                        duration: 200
                    }
                }
            }
        }

        Rectangle {
            anchors.left: shell.right
            anchors.verticalCenter: parent.verticalCenter
            width: 2
            height: 5
            radius: 1
            color: Theme.overlay0
        }

        Shape {
            anchors.centerIn: shell
            implicitWidth: 7
            implicitHeight: 10
            visible: root.charging
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                fillColor: Theme.base
                strokeColor: root.levelColor
                strokeWidth: 0.8

                PathSvg {
                    path: "M 4.3,0 L 0.5,5.8 L 3.1,5.8 L 2.7,10 L 6.5,4.2 L 3.9,4.2 Z"
                }
            }
        }
    }

    Text {
        text: root.percent + "%"
        color: Theme.text
        font.family: Theme.monoFontFamily
        font.pixelSize: 12
        font.weight: Theme.monoBoldFontWeight
    }
}
