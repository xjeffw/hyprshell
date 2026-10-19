import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland
import Quickshell.Widgets

CardPanel {
    id: root

    property var notification: null
    // What the card shows: the live notification, or a copy of it once it
    // closes so the card can fade out.
    property var content: null
    // Level notifications (e.g. change-brightness) send an int "value" hint
    // and a "current% / max%" body, which is shown like the bar's readouts.
    readonly property bool hasValue: content !== null && content.hints.value !== undefined
    signal dismissRequested
    signal expireRequested
    signal closedExternally

    function restartTimeout() {
        if (notification === null)
            return;
        const requested = notification.expireTimeout;
        hideTimer.interval = requested > 0 ? requested : 5000;
        hideTimer.restart();
    }

    onNotificationChanged: {
        if (notification !== null) {
            content = notification;
        } else if (content !== null) {
            content = {
                appName: content.appName,
                summary: content.summary,
                body: content.body,
                appIcon: content.appIcon,
                urgency: content.urgency,
                hints: {
                    value: content.hints.value
                },
                actions: Array.from(content.actions, action => ({
                            text: action.text
                        }))
            };
        }
    }

    onFadeChanged: {
        if (fade === 0 && notification === null)
            content = null;
    }

    shown: notification !== null
    visible: content !== null
    cardWidth: 460
    cardHeight: notificationContent.implicitHeight + 32
    cardBorderColor: content !== null && content.urgency === NotificationUrgency.Critical ? Theme.red : Theme.notificationBorder
    implicitWidth: shadowMargin + cardWidth + 8
    aboveWindows: true
    // Matched by the layer-rule in the niri config.
    WlrLayershell.namespace: "hyprshell-notification"

    anchors {
        top: true
        right: true
    }

    // The card is 8px below the bar and from the screen edge; on the right
    // its shadow runs off the screen.
    margins {
        top: Theme.barHeight + 8 - shadowMargin
        right: 0
    }

    Timer {
        id: hideTimer

        interval: 5000
        repeat: false
        onTriggered: root.expireRequested()
    }

    Connections {
        target: root.notification

        function onClosed() {
            root.closedExternally();
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.dismissRequested()
    }

    RowLayout {
        id: notificationContent

        anchors.fill: parent
        anchors.margins: 16
        spacing: 14

        IconImage {
            visible: root.content !== null && source.toString().length > 0
            source: root.content !== null ? root.content.appIcon : ""
            Layout.preferredWidth: visible ? 48 : 0
            Layout.preferredHeight: visible ? 48 : 0
            Layout.alignment: Qt.AlignTop
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 5

            Text {
                Layout.fillWidth: true
                visible: text.length > 0
                text: root.content !== null ? root.content.appName : ""
                color: Theme.mauve
                elide: Text.ElideRight
                font.family: Theme.fontFamily
                font.pixelSize: 15
                font.bold: true
            }

            Text {
                Layout.fillWidth: true
                text: root.content !== null ? root.content.summary : ""
                color: Theme.text
                elide: Text.ElideRight
                font.family: Theme.fontFamily
                font.pixelSize: 19
                font.bold: true
            }

            Text {
                Layout.fillWidth: true
                visible: text.length > 0
                text: root.content !== null ? root.content.body : ""
                textFormat: Text.StyledText
                color: root.hasValue ? Theme.text : Theme.subtext0
                wrapMode: Text.Wrap
                maximumLineCount: 4
                elide: Text.ElideRight
                font.family: root.hasValue ? Theme.monoFontFamily : Theme.fontFamily
                font.pixelSize: root.hasValue ? 22 : 16
                font.weight: root.hasValue ? Theme.monoBoldFontWeight : Font.Normal
            }

            RowLayout {
                visible: root.content !== null && root.content.actions.length > 0
                Layout.fillWidth: true
                spacing: 6

                Repeater {
                    model: root.content !== null ? root.content.actions : []

                    delegate: Button {
                        required property var modelData

                        text: modelData.text
                        font.family: Theme.fontFamily
                        font.pixelSize: 15
                        palette.button: Theme.surface0
                        palette.buttonText: Theme.text
                        // Actions can't be invoked once the notification
                        // has closed and is fading out.
                        onClicked: {
                            if (root.notification === null)
                                return;
                            modelData.invoke();
                            root.dismissRequested();
                        }
                    }
                }
            }
        }
    }
}
