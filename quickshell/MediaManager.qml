import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

Scope {
    id: root

    readonly property var players: Mpris.players.values
    property var selectedPlayer: null
    readonly property var player: selectedPlayer

    function refreshSelection() {
        if (selectedPlayer !== null && players.indexOf(selectedPlayer) >= 0)
            return;

        selectedPlayer = null;
        for (let i = 0; i < players.length; i++) {
            if (players[i].isPlaying)
                selectedPlayer = players[i];
        }
        if (selectedPlayer === null && players.length > 0)
            selectedPlayer = players[0];
    }

    function playPause() {
        if (player !== null && player.canTogglePlaying)
            player.togglePlaying();
    }

    function selectNextPlayer() {
        if (players.length === 0) {
            selectedPlayer = null;
            return;
        }

        const currentIndex = players.indexOf(player);
        selectedPlayer = players[(Math.max(0, currentIndex) + 1) % players.length];
    }

    function nextTrack() {
        if (player !== null && player.canGoNext)
            player.next();
    }

    function previousTrack() {
        if (player !== null && player.canGoPrevious)
            player.previous();
    }

    function seekDelta(delta) {
        if (player === null || !player.canSeek)
            return;

        if (player.positionSupported) {
            let position = Math.max(0, player.position + delta);
            if (player.lengthSupported)
                position = Math.min(position, player.length);
            player.position = position;
        } else {
            player.seek(delta);
        }
    }

    onPlayersChanged: refreshSelection()
    Component.onCompleted: refreshSelection()

    IpcHandler {
        target: "mpris"

        function playPause(): void {
            root.playPause();
        }

        function selectNextPlayer(): void {
            root.selectNextPlayer();
        }

        function nextTrack(): void {
            root.nextTrack();
        }

        function previousTrack(): void {
            root.previousTrack();
        }

        function seekDelta(delta: real): void {
            root.seekDelta(delta);
        }
    }
}
