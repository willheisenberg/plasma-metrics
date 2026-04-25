import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root

    // --- Metric properties (updated by script output) ---
    property int cpuUsage: 0
    property int cpuTemp: 0
    property int gpuUsage: 0
    property string gpuType: "none"
    property int ramUsage: 0
    property string ramTotalGb: "0"
    property string ramUsedGb: "0"
    property bool hasSwap: false
    property int swapUsage: 0
    property bool hasZram: false
    property int zramUsage: 0
    property int diskUsage: 0
    property string diskTotal: "0"
    property string diskUsed: "0"
    property string netRx: "0 B/s"
    property string netTx: "0 B/s"
    property string netIface: ""
    property int netRxBytes: 0
    property int netTxBytes: 0
    // --- Configuration bindings ---
    property int updateInterval: Plasmoid.configuration.updateInterval || 2000
    property int panelIconSize: Plasmoid.configuration.panelIconSize || 16
    property int panelTextSize: Plasmoid.configuration.panelTextSize || 12
    property int panelIconTextSpacing: Plasmoid.configuration.panelIconTextSpacing === undefined ? 2 : Plasmoid.configuration.panelIconTextSpacing
    property int panelMetricSpacing: Plasmoid.configuration.panelMetricSpacing || 6
    property bool showCpu: Plasmoid.configuration.showCpu === undefined ? true : Plasmoid.configuration.showCpu
    property bool showGpu: Plasmoid.configuration.showGpu === undefined ? true : Plasmoid.configuration.showGpu
    property bool showTemp: Plasmoid.configuration.showTemp === undefined ? true : Plasmoid.configuration.showTemp
    property bool showRam: Plasmoid.configuration.showRam === undefined ? true : Plasmoid.configuration.showRam
    property bool showSwapInPanel: Plasmoid.configuration.showSwapInPanel === undefined ? true : Plasmoid.configuration.showSwapInPanel
    property bool showZramInPanel: Plasmoid.configuration.showZramInPanel === undefined ? true : Plasmoid.configuration.showZramInPanel
    property bool showSwap: Plasmoid.configuration.showSwap === undefined ? false : Plasmoid.configuration.showSwap
    property bool showZram: Plasmoid.configuration.showZram === undefined ? false : Plasmoid.configuration.showZram
    property bool showDisk: Plasmoid.configuration.showDisk === undefined ? true : Plasmoid.configuration.showDisk
    property bool showNetwork: Plasmoid.configuration.showNetwork === undefined ? true : Plasmoid.configuration.showNetwork
    // --- Resolve script path relative to plasmoid package ---
    readonly property string scriptPath: decodeURIComponent(Qt.resolvedUrl("../scripts/metrics.sh").toString().replace(/^file:\/\//, ""))
    readonly property string scriptCommand: "bash '" + root.scriptPath.replace(/'/g, "'\\''") + "'"

    preferredRepresentation: compactRepresentation
    // Tooltip
    Plasmoid.icon: "utilities-system-monitor"
    toolTipMainText: "System Metrics"
    toolTipSubText: {
        let parts = [];
        parts.push("CPU: " + cpuUsage + "% · " + cpuTemp + "°C");
        if (gpuType !== "none")
            parts.push("GPU: " + gpuUsage + "% (" + gpuType + ")");

        parts.push("RAM: " + ramUsedGb + " / " + ramTotalGb + " GB (" + ramUsage + "%)");
        parts.push("Net: ↓" + netRx + " ↑" + netTx);
        return parts.join("\n");
    }

    // --- DataSource: runs the metrics shell script ---
    Plasma5Support.DataSource {
        id: executable

        function exec(cmd) {
            connectSource(cmd);
        }

        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => {
            let stdout = data["stdout"] || "";
            let exitCode = data["exit code"];
            if (exitCode === 0 && stdout.length > 0) {
                try {
                    let metrics = JSON.parse(stdout);
                    root.cpuUsage = metrics.cpu || 0;
                    root.cpuTemp = metrics.cpu_temp || 0;
                    root.gpuUsage = metrics.gpu || 0;
                    root.gpuType = metrics.gpu_type || "none";
                    root.ramUsage = metrics.ram || 0;
                    root.ramTotalGb = metrics.ram_total_gb || "0";
                    root.ramUsedGb = metrics.ram_used_gb || "0";
                    root.hasSwap = metrics.has_swap === undefined ? false : metrics.has_swap;
                    root.swapUsage = metrics.swap || 0;
                    root.hasZram = metrics.has_zram === undefined ? false : metrics.has_zram;
                    root.zramUsage = metrics.zram || 0;
                    root.diskUsage = metrics.disk || 0;
                    root.diskTotal = metrics.disk_total || "0";
                    root.diskUsed = metrics.disk_used || "0";
                    root.netRx = metrics.net_rx || "0 B/s";
                    root.netTx = metrics.net_tx || "0 B/s";
                    root.netIface = metrics.net_iface || "";
                    root.netRxBytes = metrics.net_rx_bytes || 0;
                    root.netTxBytes = metrics.net_tx_bytes || 0;
                } catch (e) {
                    console.error("System Metrics: JSON parse error:", e, "stdout:", stdout);
                }
            }
            disconnectSource(sourceName);
        }
    }

    // --- Polling timer ---
    Timer {
        id: updateTimer

        interval: root.updateInterval
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (executable.connectedSources.length === 0)
                executable.exec(root.scriptCommand);

        }
    }

    // --- Representations ---
    // Pass all data as explicit properties to avoid parent-chain issues
    compactRepresentation: CompactRepresentation {
        plasmoidItem: root
        cpuUsage: root.cpuUsage
        cpuTemp: root.cpuTemp
        gpuUsage: root.gpuUsage
        gpuType: root.gpuType
        ramUsage: root.ramUsage
        hasSwap: root.hasSwap
        swapUsage: root.swapUsage
        hasZram: root.hasZram
        zramUsage: root.zramUsage
        diskUsage: root.diskUsage
        netRx: root.netRx
        netTx: root.netTx
        showCpu: root.showCpu
        showGpu: root.showGpu
        showTemp: root.showTemp
        showRam: root.showRam
        iconSize: root.panelIconSize
        textSize: root.panelTextSize
        iconTextSpacing: root.panelIconTextSpacing
        metricSpacing: root.panelMetricSpacing
        showSwap: root.showSwapInPanel
        showZram: root.showZramInPanel
        showDisk: root.showDisk
        showNetwork: root.showNetwork
    }

    fullRepresentation: FullRepresentation {
        cpuUsage: root.cpuUsage
        cpuTemp: root.cpuTemp
        gpuUsage: root.gpuUsage
        gpuType: root.gpuType
        ramUsage: root.ramUsage
        ramTotalGb: root.ramTotalGb
        ramUsedGb: root.ramUsedGb
        hasSwap: root.hasSwap
        swapUsage: root.swapUsage
        hasZram: root.hasZram
        zramUsage: root.zramUsage
        diskUsage: root.diskUsage
        diskTotal: root.diskTotal
        diskUsed: root.diskUsed
        netRx: root.netRx
        netTx: root.netTx
        netIface: root.netIface
        showSwap: root.showSwap
        showZram: root.showZram
    }

}
