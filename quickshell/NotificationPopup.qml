import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets

PanelWindow {
    id: root

    property var notification: null
    signal dismissRequested
    signal expireRequested
    signal closedExternally

    function restartTimeout() {
        if (notification === null)
            return;
        const requested = notification.expireTimeout * 1000;
        hideTimer.interval = requested > 0 ? requested : 6000;
        hideTimer.restart();
    }

    visible: notification !== null
    color: "transparent"
    implicitWidth: 390
    implicitHeight: notificationCard.implicitHeight
    exclusiveZone: 0
    aboveWindows: true

    anchors {
        top: true
        right: true
    }

    margins {
        top: Theme.barHeight + 8
        right: 8
    }

    Timer {
        id: hideTimer

        interval: 6000
        repeat: false
        onTriggered: root.expireRequested()
    }

    Connections {
        target: root.notification

        function onClosed() {
            root.closedExternally();
        }
    }

    Rectangle {
        id: notificationCard

        anchors.fill: parent
        implicitHeight: notificationContent.implicitHeight + 24
        radius: 10
        color: Theme.base
        border.width: 1
        border.color: root.notification !== null && root.notification.urgency === NotificationUrgency.Critical ? Theme.red : Theme.surface1

        RowLayout {
            id: notificationContent

            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            IconImage {
                visible: root.notification !== null && source.toString().length > 0
                source: root.notification !== null ? root.notification.appIcon : ""
                Layout.preferredWidth: visible ? 40 : 0
                Layout.preferredHeight: visible ? 40 : 0
                Layout.alignment: Qt.AlignTop
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    Layout.fillWidth: true
                    visible: text.length > 0
                    text: root.notification !== null ? root.notification.appName : ""
                    color: Theme.mauve
                    elide: Text.ElideRight
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    font.bold: true
                }

                Text {
                    Layout.fillWidth: true
                    text: root.notification !== null ? root.notification.summary : ""
                    color: Theme.text
                    elide: Text.ElideRight
                    font.family: Theme.fontFamily
                    font.pixelSize: 14
                    font.bold: true
                }

                Text {
                    Layout.fillWidth: true
                    visible: text.length > 0
                    text: root.notification !== null ? root.notification.body : ""
                    textFormat: Text.PlainText
                    color: Theme.subtext0
                    wrapMode: Text.Wrap
                    maximumLineCount: 4
                    elide: Text.ElideRight
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                }

                RowLayout {
                    visible: root.notification !== null && root.notification.actions.length > 0
                    Layout.fillWidth: true
                    spacing: 6

                    Repeater {
                        model: root.notification !== null ? root.notification.actions : []

                        delegate: Button {
                            required property var modelData

                            text: modelData.text
                            palette.button: Theme.surface0
                            palette.buttonText: Theme.text
                            onClicked: {
                                modelData.invoke();
                                root.dismissRequested();
                            }
                        }
                    }
                }
            }

            ToolButton {
                Layout.alignment: Qt.AlignTop
                text: "×"
                palette.buttonText: Theme.text
                onClicked: root.dismissRequested()
            }
        }
    }
}
