import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland

// A panel showing one card with a shadow, styled like the notification popup:
// lightly tinted glass under niri. The card fades in and out as `shown`
// changes; children are placed in the card.
PanelWindow {
    id: root

    property bool shown: false
    // 1 while shown, animated so the card fades in and out.
    property real fade: shown ? 1 : 0
    property int cardWidth: 0
    property int cardHeight: 0
    property color cardBorderColor: Theme.notificationBorder
    // Room around the card for its shadow.
    readonly property int shadowMargin: 36
    default property alias cardData: card.data

    Behavior on fade {
        id: fadeBehavior

        NumberAnimation {
            duration: 250
            easing.type: fadeBehavior.targetValue === 1 ? Easing.InQuad : Easing.OutQuad
        }
    }

    color: "transparent"
    implicitWidth: shadowMargin + cardWidth + shadowMargin
    implicitHeight: shadowMargin + cardHeight + shadowMargin
    exclusiveZone: 0
    // Only the card takes clicks, not the shadow around it.
    mask: cardRegion
    BackgroundEffect.blurRegion: cardRegion
    // Under niri the compositor fades the whole surface, so the blur behind
    // the card fades with it (needs alpha-modifier support, see the niri fork).
    AlphaModifier.opacity: Niri.available ? fade : 1

    Region {
        id: cardRegion

        item: card
        radius: card.radius
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
                x: card.x
                y: card.y
                width: card.width
                height: card.height
                radius: card.radius
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
                x: card.x
                y: card.y
                width: card.width
                height: card.height
                radius: card.radius
            }
        }

        Rectangle {
            id: card

            x: root.shadowMargin
            y: root.shadowMargin
            width: root.cardWidth
            height: root.cardHeight
            radius: 12
            color: Theme.notificationBackground
            border.width: 1
            border.color: root.cardBorderColor
        }
    }
}
