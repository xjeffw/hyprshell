import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris

BarSection {
    id: root

    readonly property var players: Mpris.players.values
    property var selectedPlayer: null
    readonly property var player: {
        if (selectedPlayer !== null && players.indexOf(selectedPlayer) >= 0)
            return selectedPlayer;
        for (let i = 0; i < players.length; i++) {
            if (players[i].isPlaying)
                return players[i];
        }
        return players.length > 0 ? players[0] : null;
    }

    visible: player !== null
    interactive: true
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    tooltipText: player === null ? "" : player.identity + " — left click: play/pause; right click: next player; scroll: seek"

    onPlayersChanged: {
        if (selectedPlayer !== null && players.indexOf(selectedPlayer) < 0)
            selectedPlayer = null;
    }

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
        if (mouse.button === Qt.LeftButton && root.player.canTogglePlaying)
            root.player.togglePlaying();
        else if (mouse.button === Qt.RightButton && root.players.length > 0) {
            const currentIndex = Math.max(0, root.players.indexOf(root.player));
            root.selectedPlayer = root.players[(currentIndex + 1) % root.players.length];
        }
    }

    onWheel: wheel => {
        if (root.player !== null && root.player.canSeek)
            root.player.seek(wheel.angleDelta.y > 0 ? -10 : 10);
    }
}
