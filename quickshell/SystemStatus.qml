import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root

    required property var stats
    spacing: 4

    BarSection {
        tooltipText: "CPU usage"

        Text {
            text: "CPU"
            color: Theme.peach
            font.family: Theme.fontFamily
            font.pixelSize: 11
            font.bold: true
        }

        Text {
            text: Math.round(root.stats.cpuPercent) + "%"
            color: Theme.text
            font.family: Theme.monoFontFamily
            font.pixelSize: 12
            font.weight: Theme.monoBoldFontWeight
        }

        Text {
            visible: root.stats.cpuTemp > 0
            text: Math.round(root.stats.cpuTemp) + "°"
            color: Theme.subtext0
            font.family: Theme.monoFontFamily
            font.pixelSize: 12
            font.weight: Theme.monoFontWeight
        }

        Text {
            visible: root.stats.cpuFrequency > 0
            text: root.stats.cpuFrequency.toFixed(1) + "G"
            color: Theme.subtext0
            font.family: Theme.monoFontFamily
            font.pixelSize: 12
            font.weight: Theme.monoFontWeight
        }
    }

    BarSection {
        tooltipText: "Memory: " + root.stats.memoryUsed.toFixed(1) + " / " + root.stats.memoryTotal.toFixed(1) + " GiB"

        Text {
            text: "MEM"
            color: Theme.mauve
            font.family: Theme.fontFamily
            font.pixelSize: 11
            font.bold: true
        }

        Text {
            text: Math.round(root.stats.memoryPercent) + "%"
            color: Theme.text
            font.family: Theme.monoFontFamily
            font.pixelSize: 12
            font.weight: Theme.monoBoldFontWeight
        }
    }
}
