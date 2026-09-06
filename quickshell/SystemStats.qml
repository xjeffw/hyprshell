import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root

    property real cpuPercent: 0
    property real cpuTemp: 0
    property real cpuFrequency: 0
    property real memoryPercent: 0
    property real memoryUsed: 0
    property real memoryTotal: 0
    property bool batteryAvailable: false
    property int batteryPercent: 0
    property string batteryStatus: "Unknown"

    function update(output) {
        try {
            const data = JSON.parse(output.trim());
            cpuPercent = data.cpu_percent || 0;
            cpuTemp = data.cpu_temp || 0;
            cpuFrequency = data.cpu_frequency || 0;
            memoryPercent = data.memory_percent || 0;
            memoryUsed = data.memory_used || 0;
            memoryTotal = data.memory_total || 0;
            batteryAvailable = data.battery_present === 1;
            batteryPercent = data.battery_percent || 0;
            batteryStatus = data.battery_status || "Unknown";
        } catch (error) {
            console.warn("Unable to parse system statistics:", error);
        }
    }

    Process {
        id: statsProcess

        command: ["bash", Quickshell.shellDir + "/scripts/system-stats.sh"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: root.update(text)
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            if (!statsProcess.running)
                statsProcess.running = true;
        }
    }
}
