import QtQuick
import QtQuick.Layouts

BarSection {
    id: root

    required property var manager
    readonly property var player: manager.player

    visible: player !== null
    interactive: true
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    tooltipText: player === null ? "" : player.identity + " — left click: play/pause; right click: next player; scroll: seek"

    Text {
        text: root.player !== null && root.player.isPlaying ? "▶" : "Ⅱ"
        color: root.player !== null && root.player.isPlaying ? Theme.green : Theme.subtext0
        font.pixelSize: 13
    }

    Text {
        Layout.maximumWidth: 420
        text: {
            if (root.player === null)
                return "";
            const artist = root.player.trackArtist;
            const title = root.player.trackTitle || root.player.identity;
            return artist.length > 0 ? artist + " — " + title : title;
        }
        color: Theme.text
        elide: Text.ElideRight
        font.family: Theme.fontFamily
        font.pixelSize: 13
        font.bold: true
    }

    onClicked: mouse => {
        if (root.player === null)
            return;
        if (mouse.button === Qt.LeftButton)
            root.manager.playPause();
        else if (mouse.button === Qt.RightButton)
            root.manager.selectNextPlayer();
    }

    onWheel: wheel => {
        root.manager.seekDelta(wheel.angleDelta.y > 0 ? -10 : 10);
    }
}
