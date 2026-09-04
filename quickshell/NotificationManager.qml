import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Notifications

Scope {
    id: root

    property var activeNotification: null
    property var targetScreen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null

    function focusedScreen() {
        const monitor = Hyprland.focusedMonitor;
        if (monitor !== null) {
            for (let i = 0; i < Quickshell.screens.length; i++) {
                if (Quickshell.screens[i].name === monitor.name)
                    return Quickshell.screens[i];
            }
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
        bodyMarkupSupported: false
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
