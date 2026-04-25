import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: configRoot

    property alias cfg_updateInterval: updateIntervalSpinBox.value
    property alias cfg_showCpu: showCpuCheck.checked
    property alias cfg_showGpu: showGpuCheck.checked
    property alias cfg_showTemp: showTempCheck.checked
    property alias cfg_showRam: showRamCheck.checked
    property alias cfg_showSwap: showSwapCheck.checked
    property alias cfg_showZram: showZramCheck.checked
    property alias cfg_showDisk: showDiskCheck.checked
    property alias cfg_showNetwork: showNetworkCheck.checked

    Kirigami.FormLayout {
        anchors.fill: parent

        // --- Update Interval ---
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

        // --- Panel Metrics ---
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
            id: showSwapCheck
            Kirigami.FormData.label: "Swap usage:"
            checked: cfg_showSwap
        }

        QQC2.CheckBox {
            id: showZramCheck
            Kirigami.FormData.label: "ZRAM usage:"
            checked: cfg_showZram
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
    }
}
