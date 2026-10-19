import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Notifications

Scope {
    id: root

    property var activeNotification: null
    property var targetScreen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null

    function focusedScreenName() {
        if (Niri.available)
            return Niri.focusedOutput;
        const monitor = Hyprland.focusedMonitor;
        return monitor !== null ? monitor.name : "";
    }

    function focusedScreen() {
        const name = focusedScreenName();
        for (let i = 0; i < Quickshell.screens.length; i++) {
            if (Quickshell.screens[i].name === name)
                return Quickshell.screens[i];
        }
        return Quickshell.screens.length > 0 ? Quickshell.screens[0] : null;
    }

    function receive(notification) {
        if (activeNotification !== null && activeNotification !== notification)
            activeNotification.dismiss();

        notification.tracked = true;
        targetScreen = focusedScreen();
        activeNotification = notification;
        popup.restartTimeout();
    }

    function close(expired) {
        const notification = activeNotification;
        activeNotification = null;
        if (notification === null)
            return;
        if (expired)
            notification.expire();
        else
            notification.dismiss();
    }

    NotificationServer {
        keepOnReload: false
        bodySupported: true
        bodyMarkupSupported: true
        actionsSupported: true
        imageSupported: true
        onNotification: notification => root.receive(notification)
    }

    NotificationPopup {
        id: popup

        screen: root.targetScreen
        notification: root.activeNotification
        onDismissRequested: root.close(false)
        onExpireRequested: root.close(true)
        onClosedExternally: root.activeNotification = null
    }
}
