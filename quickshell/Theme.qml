pragma Singleton

import QtQuick
import Quickshell

Singleton {
    readonly property string defaultColorTheme: "macchiato"
    readonly property string colorTheme: {
        const configuredTheme = Quickshell.env("HYPRSHELL_THEME");

        if (configuredTheme === null || configuredTheme.trim() === "")
            return defaultColorTheme;

        const normalizedTheme = configuredTheme.trim().toLowerCase();
        if (normalizedTheme !== "macchiato" && normalizedTheme !== "mocha") {
            console.warn(`Unknown HYPRSHELL_THEME '${configuredTheme}'; using '${defaultColorTheme}'`);
            return defaultColorTheme;
        }

        return normalizedTheme;
    }

    readonly property QtObject palette: colorTheme === "mocha" ? mocha : macchiato
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
    readonly property color mantle: palette.mantle
    readonly property color base: palette.base

    readonly property int barHeight: 38
    readonly property int controlHeight: 28
    readonly property int radius: 7
    readonly property string fontFamily: "sans-serif"
    readonly property string monoFontFamily: "monospace"
}
