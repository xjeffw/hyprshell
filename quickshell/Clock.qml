import QtQuick
import QtQuick.Layouts
import Quickshell

RowLayout {
    id: root

    spacing: 4

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    BarSection {
        tooltipText: Qt.formatDateTime(clock.date, "dddd, MMMM d, yyyy")

        Text {
            text: "DATE"
            color: Theme.blue
            font.family: Theme.fontFamily
            font.pixelSize: 11
            font.bold: true
        }

        Text {
            text: Qt.formatDateTime(clock.date, "ddd MM/dd/yy")
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.bold: true
        }
    }

    BarSection {
        tooltipText: "Local time"

        Text {
            text: "TIME"
            color: Theme.mauve
            font.family: Theme.fontFamily
            font.pixelSize: 11
            font.bold: true
        }

        Text {
            text: Qt.formatDateTime(clock.date, "h:mm AP")
            color: Theme.text
            font.family: Theme.monoFontFamily
            font.pixelSize: 12
            font.bold: true
        }
    }
}
