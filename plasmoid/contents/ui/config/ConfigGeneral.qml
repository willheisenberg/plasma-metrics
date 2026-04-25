import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami

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

            Kirigami.FormData.label: "GPU usage:"
            checked: cfg_showGpu
        }

        QQC2.CheckBox {
            id: showTempCheck

            Kirigami.FormData.label: "CPU temperature:"
            checked: cfg_showTemp
        }

        QQC2.CheckBox {
            id: showRamCheck

            Kirigami.FormData.label: "RAM usage:"
            checked: cfg_showRam
        }

        QQC2.CheckBox {
            id: showZramInPanelCheck

            Kirigami.FormData.label: "ZRAM usage:"
            checked: cfg_showZramInPanel
        }

        QQC2.CheckBox {
            id: showSwapInPanelCheck

            Kirigami.FormData.label: "Swap usage:"
            checked: cfg_showSwapInPanel
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

            Kirigami.FormData.label: "Show Swap when empty:"
            checked: cfg_showSwap
        }

        QQC2.CheckBox {
            id: showZramCheck

            Kirigami.FormData.label: "Show ZRAM when empty:"
            checked: cfg_showZram
        }

    }

}
