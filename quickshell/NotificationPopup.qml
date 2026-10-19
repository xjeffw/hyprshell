import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland
import Quickshell.Widgets

PanelWindow {
    id: root

    property var notification: null
    // What the card shows: the live notification, or a copy of it once it
    // closes so the card can fade out.
    property var content: null
    // Level notifications (e.g. change-brightness) send an int "value" hint
    // and a "current% / max%" body, which is shown like the bar's readouts.
    readonly property bool hasValue: content !== null && content.hints.value !== undefined
    readonly property int cardWidth: 460
    // Room around the card for its shadow.
    readonly property int shadowMargin: 36
    // 1 while a notification is open, animated so the card fades in and out.
    property real fade: notification !== null ? 1 : 0
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

    Behavior on fade {
        NumberAnimation {
            duration: 200
            easing.type: Easing.InOutQuad
        }
    }

    visible: content !== null
    color: "transparent"
    implicitWidth: shadowMargin + cardWidth + 8
    implicitHeight: shadowMargin + notificationCard.height + shadowMargin
    exclusiveZone: 0
    aboveWindows: true
    // Matched by the layer-rule in the niri config.
    WlrLayershell.namespace: "hyprshell-notification"
    // Only the card takes clicks, not the shadow around it.
    mask: cardRegion
    BackgroundEffect.blurRegion: cardRegion
    // Under niri the compositor fades the whole surface, so the blur behind
    // the card fades with it (needs alpha-modifier support, see the niri fork).
    AlphaModifier.opacity: Niri.available ? fade : 1

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

    Region {
        id: cardRegion

        item: notificationCard
        radius: notificationCard.radius
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

    Item {
        anchors.fill: parent
        opacity: Niri.available ? 1 : root.fade

        // Shadow like niri's window shadows, which aren't drawn behind the
        // translucent card either.
        Item {
            anchors.fill: parent
            layer.enabled: true
            layer.effect: MultiEffect {
                maskEnabled: true
                maskInverted: true
                maskSource: cardMask
            }

            RectangularShadow {
                x: notificationCard.x
                y: notificationCard.y
                width: notificationCard.width
                height: notificationCard.height
                radius: notificationCard.radius
                offset: Qt.vector2d(0, 5)
                blur: 30
                spread: 5
                color: "#77000000"
            }
        }

        Item {
            id: cardMask

            anchors.fill: parent
            visible: false
            layer.enabled: true

            Rectangle {
                x: notificationCard.x
                y: notificationCard.y
                width: notificationCard.width
                height: notificationCard.height
                radius: notificationCard.radius
            }
        }

        Rectangle {
            id: notificationCard

            x: root.shadowMargin
            y: root.shadowMargin
            width: root.cardWidth
            height: implicitHeight
            implicitHeight: notificationContent.implicitHeight + 32
            radius: 12
            color: Theme.notificationBackground
            border.width: 1
            border.color: root.content !== null && root.content.urgency === NotificationUrgency.Critical ? Theme.red : Theme.notificationBorder

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
    }
}
