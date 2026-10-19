pragma Singleton

import QtQuick
import Quickshell

Singleton {
    readonly property string defaultColorTheme: "mocha"
    readonly property string colorTheme: {
        const configuredTheme = Quickshell.env("HYPRSHELL_THEME");

        if (configuredTheme === null || configuredTheme.trim() === "")
            return defaultColorTheme;

        const normalizedTheme = configuredTheme.trim().toLowerCase();
        if (normalizedTheme !== "frappe" && normalizedTheme !== "macchiato" && normalizedTheme !== "mocha") {
            console.warn(`Unknown HYPRSHELL_THEME '${configuredTheme}'; using '${defaultColorTheme}'`);
            return defaultColorTheme;
        }

        return normalizedTheme;
    }

    readonly property QtObject palette: colorTheme === "frappe" ? frappe : colorTheme === "macchiato" ? macchiato : mocha
    readonly property QtObject frappe: CatppuccinFrappe {}
    readonly property QtObject macchiato: CatppuccinMacchiato {}
    readonly property QtObject mocha: CatppuccinMocha {}

    readonly property color rosewater: palette.rosewater
    readonly property color red: palette.red
    readonly property color peach: palette.peach
    readonly property color yellow: palette.yellow
    readonly property color green: palette.green
    readonly property color teal: palette.teal
    readonly property color blue: palette.blue
    readonly property color mauve: palette.mauve
    readonly property color text: palette.text
    readonly property color subtext0: palette.subtext0
    readonly property color overlay0: palette.overlay0
    readonly property color surface0: palette.surface0
    readonly property color surface1: palette.surface1
    readonly property color surface2: palette.surface2
    readonly property color mantle: palette.mantle
    readonly property color base: palette.base

    // Under niri the bar and its sections are translucent black over the
    // wallpaper, and more compact.
    readonly property color barBackground: Niri.available ? Qt.rgba(0, 0, 0, 0.5) : mantle
    readonly property color sectionBackground: Niri.available ? Qt.rgba(0, 0, 0, 0.5) : surface0
    readonly property color sectionBorder: Niri.available ? Qt.lighter(surface1, 1.4) : surface1

    // Notifications are lightly tinted glass (the popup asks niri to blur
    // behind it) bordered like the bar sections.
    readonly property color notificationBackground: Niri.available ? Qt.rgba(0, 0, 0, 0.3) : base
    readonly property color notificationBorder: Niri.available ? sectionBorder : surface1

    readonly property int barHeight: Niri.available ? 32 : 38
    readonly property int controlHeight: Niri.available ? 24 : 28
    readonly property int radius: 7
    readonly property string fontFamily: "sans-serif"
    readonly property string monoFontFamily: "monospace"
    readonly property int monoFontWeight: Math.min(Font.Black, Font.Normal + 200)
    readonly property int monoBoldFontWeight: Math.min(Font.Black, Font.Bold + 200)
}
