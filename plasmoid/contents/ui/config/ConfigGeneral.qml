import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as Plasma5Support

KCM.SimpleKCM {
    id: configRoot

    property alias cfg_updateInterval: updateIntervalSpinBox.value
    property alias cfg_panelIconSize: panelIconSizeSpinBox.value
    property alias cfg_panelTextSize: panelTextSizeSpinBox.value
    property alias cfg_panelIconTextSpacing: panelIconTextSpacingSpinBox.value
    property alias cfg_panelMetricSpacing: panelMetricSpacingSpinBox.value
    property alias cfg_showCpu: showCpuCheck.checked
    property alias cfg_showGpu: showGpuCheck.checked
    property alias cfg_showTemp: showTempCheck.checked
    property alias cfg_showRam: showRamCheck.checked
    property alias cfg_showSwapInPanel: showSwapInPanelCheck.checked
    property alias cfg_showZramInPanel: showZramInPanelCheck.checked
    property alias cfg_showSwap: showSwapCheck.checked
    property alias cfg_showZram: showZramCheck.checked
    property alias cfg_showDisk: showDiskCheck.checked
    property alias cfg_showNetwork: showNetworkCheck.checked
    readonly property string scriptPath: decodeURIComponent(Qt.resolvedUrl("../../scripts/metrics.sh").toString().replace(/^file:\/\//, ""))
    readonly property string scriptCommand: "bash '" + configRoot.scriptPath.replace(/'/g, "'\\''") + "'"
    property bool metricProbeCompleted: false
    property bool gpuMetricAvailable: true
    property bool tempMetricAvailable: true
    property bool swapMetricAvailable: true
    property bool zramMetricAvailable: true

    Plasma5Support.DataSource {
        id: metricProbe

        engine: "executable"
        connectedSources: []

        function exec(cmd) {
            connectSource(cmd);
        }

        onNewData: (sourceName, data) => {
            const stdout = data["stdout"] || "";
            const exitCode = data["exit code"];

            if (exitCode === 0 && stdout.length > 0) {
                try {
                    const metrics = JSON.parse(stdout);
                    configRoot.gpuMetricAvailable = (metrics.gpu_type || "none") !== "none";
                    configRoot.tempMetricAvailable = (metrics.cpu_temp || 0) > 0;
                    configRoot.swapMetricAvailable = metrics.has_swap === undefined ? true : metrics.has_swap;
                    configRoot.zramMetricAvailable = metrics.has_zram === undefined ? true : metrics.has_zram;

                    if (!configRoot.gpuMetricAvailable)
                        showGpuCheck.checked = false;
                    if (!configRoot.tempMetricAvailable)
                        showTempCheck.checked = false;
                    if (!configRoot.swapMetricAvailable) {
                        showSwapInPanelCheck.checked = false;
                        showSwapCheck.checked = false;
                    }
                    if (!configRoot.zramMetricAvailable) {
                        showZramInPanelCheck.checked = false;
                        showZramCheck.checked = false;
                    }
                } catch (e) {
                    console.error("System Metrics config probe parse error:", e, "stdout:", stdout);
                }
            }

            configRoot.metricProbeCompleted = true;
            disconnectSource(sourceName);
        }
    }

    Component.onCompleted: {
        metricProbe.exec(configRoot.scriptCommand);
    }

    Kirigami.FormLayout {
        anchors.fill: parent

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "General"
        }

        QQC2.SpinBox {
            id: updateIntervalSpinBox

            Kirigami.FormData.label: "Update interval (ms):"
            from: 1000
            to: 10000
            stepSize: 500
            value: cfg_updateInterval
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Panel Layout"
        }

        QQC2.SpinBox {
            id: panelIconSizeSpinBox

            Kirigami.FormData.label: "Icon size (px):"
            from: 10
            to: 40
            stepSize: 1
            value: cfg_panelIconSize
        }

        QQC2.SpinBox {
            id: panelTextSizeSpinBox

            Kirigami.FormData.label: "Text size (px):"
            from: 8
            to: 32
            stepSize: 1
            value: cfg_panelTextSize
        }

        QQC2.SpinBox {
            id: panelIconTextSpacingSpinBox

            Kirigami.FormData.label: "Icon/text spacing (px):"
            from: 0
            to: 20
            stepSize: 1
            value: cfg_panelIconTextSpacing
        }

        QQC2.SpinBox {
            id: panelMetricSpacingSpinBox

            Kirigami.FormData.label: "Metric spacing (px):"
            from: 0
            to: 40
            stepSize: 1
            value: cfg_panelMetricSpacing
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Visible Metrics (Panel)"
        }

        QQC2.CheckBox {
            id: showCpuCheck

            Kirigami.FormData.label: "CPU usage:"
            checked: cfg_showCpu
        }

        QQC2.CheckBox {
            id: showGpuCheck

            Kirigami.FormData.label: configRoot.gpuMetricAvailable ? "GPU usage:" : "GPU usage (not available):"
            checked: cfg_showGpu
            enabled: configRoot.gpuMetricAvailable
        }

        QQC2.CheckBox {
            id: showTempCheck

            Kirigami.FormData.label: configRoot.tempMetricAvailable ? "CPU temperature:" : "CPU temperature (not available):"
            checked: cfg_showTemp
            enabled: configRoot.tempMetricAvailable
        }

        QQC2.CheckBox {
            id: showRamCheck

            Kirigami.FormData.label: "RAM usage:"
            checked: cfg_showRam
        }

        QQC2.CheckBox {
            id: showZramInPanelCheck

            Kirigami.FormData.label: configRoot.zramMetricAvailable ? "ZRAM usage:" : "ZRAM usage (not available):"
            checked: cfg_showZramInPanel
            enabled: configRoot.zramMetricAvailable
        }

        QQC2.CheckBox {
            id: showSwapInPanelCheck

            Kirigami.FormData.label: configRoot.swapMetricAvailable ? "Swap usage:" : "Swap usage (not available):"
            checked: cfg_showSwapInPanel
            enabled: configRoot.swapMetricAvailable
        }

        QQC2.CheckBox {
            id: showDiskCheck

            Kirigami.FormData.label: "Disk usage:"
            checked: cfg_showDisk
        }

        QQC2.CheckBox {
            id: showNetworkCheck

            Kirigami.FormData.label: "Network throughput:"
            checked: cfg_showNetwork
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Detailed View"
        }

        QQC2.CheckBox {
            id: showSwapCheck

            Kirigami.FormData.label: configRoot.swapMetricAvailable ? "Show Swap when empty:" : "Show Swap when empty (not available):"
            checked: cfg_showSwap
            enabled: configRoot.swapMetricAvailable
        }

        QQC2.CheckBox {
            id: showZramCheck

            Kirigami.FormData.label: configRoot.zramMetricAvailable ? "Show ZRAM when empty:" : "Show ZRAM when empty (not available):"
            checked: cfg_showZram
            enabled: configRoot.zramMetricAvailable
        }

        QQC2.Label {
            visible: !configRoot.metricProbeCompleted
            text: "Detecting available metrics on this system..."
            color: Kirigami.Theme.disabledTextColor
            wrapMode: Text.WordWrap
        }

    }

}
