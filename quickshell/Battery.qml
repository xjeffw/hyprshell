import QtQuick
import Quickshell.Services.UPower

BarSection {
    id: root

    readonly property var battery: UPower.displayDevice
    readonly property bool available: battery !== null && battery.ready && battery.isPresent && battery.isLaptopBattery

    visible: available
    tooltipText: available ? "Battery: " + Math.round(battery.percentage) + "%" : ""

    Text {
        text: "BAT"
        color: root.available && root.battery.percentage <= 15 ? Theme.red : Theme.green
        font.family: Theme.fontFamily
        font.pixelSize: 11
        font.bold: true
    }

    Text {
        text: root.available ? Math.round(root.battery.percentage) + "%" : ""
        color: Theme.text
        font.family: Theme.monoFontFamily
        font.pixelSize: 12
        font.weight: Theme.monoBoldFontWeight
    }
}
