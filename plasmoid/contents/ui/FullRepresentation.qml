import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras

Item {
    id: fullRoot

    implicitWidth: Kirigami.Units.gridUnit * 18
    implicitHeight: mainColumn.implicitHeight + Kirigami.Units.largeSpacing * 2

    // --- Properties bound from main.qml ---
    property int cpuUsage: 0
    property int cpuTemp: 0
    property int gpuUsage: 0
    property string gpuType: "none"
    property int ramUsage: 0
    property string ramTotalGb: "0"
    property string ramUsedGb: "0"
    property int swapUsage: 0
    property int zramUsage: 0
    property int diskUsage: 0
    property string diskTotal: "0"
    property string diskUsed: "0"
    property string netRx: "0 B/s"
    property string netTx: "0 B/s"
    property string netIface: ""
    property bool showSwap: false
    property bool showZram: false

    // --- Color helpers ---
    function metricColor(value) {
        if (value < 50) {
            let ratio = value / 50.0
            return Qt.rgba(ratio, 0.86, 0.2, 1.0)
        } else {
            let ratio = (value - 50) / 50.0
            return Qt.rgba(1.0, (1.0 - ratio) * 0.86, 0.2, 1.0)
        }
    }

    function barColor(value) {
        if (value < 60) return Kirigami.Theme.positiveTextColor
        if (value < 85) return Kirigami.Theme.neutralTextColor
        return Kirigami.Theme.negativeTextColor
    }

    // --- Reusable metric row component ---
    component MetricRow: RowLayout {
        id: metricRowRoot
        property string icon: ""
        property string label: ""
        property string valueText: ""
        property int percentage: 0
        property string detail: ""
        property bool showBar: true

        spacing: Kirigami.Units.smallSpacing
        Layout.fillWidth: true

        // Nerd Font icon
        PlasmaComponents.Label {
            text: metricRowRoot.icon
            font.family: "Symbols Nerd Font Mono"
            font.pixelSize: Kirigami.Units.iconSizes.smallMedium
            color: Kirigami.Theme.textColor
            Layout.preferredWidth: Kirigami.Units.gridUnit * 1.5
            horizontalAlignment: Text.AlignHCenter
        }

        // Label
        PlasmaComponents.Label {
            text: metricRowRoot.label
            font.pixelSize: Kirigami.Theme.defaultFont.pixelSize
            color: Kirigami.Theme.textColor
            Layout.preferredWidth: Kirigami.Units.gridUnit * 3
        }

        // Progress bar
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: Kirigami.Units.gridUnit * 0.6
            visible: metricRowRoot.showBar

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: Kirigami.Theme.backgroundColor
                opacity: 0.4

                Rectangle {
                    width: parent.width * Math.min(metricRowRoot.percentage, 100) / 100
                    height: parent.height
                    radius: height / 2
                    color: fullRoot.barColor(metricRowRoot.percentage)

                    Behavior on width {
                        NumberAnimation {
                            duration: 400
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }

        // Value
        PlasmaComponents.Label {
            text: metricRowRoot.valueText
            font.pixelSize: Kirigami.Theme.defaultFont.pixelSize
            font.bold: true
            color: fullRoot.metricColor(metricRowRoot.percentage)
            Layout.preferredWidth: Kirigami.Units.gridUnit * 2.5
            horizontalAlignment: Text.AlignRight
        }

        // Detail text (optional)
        PlasmaComponents.Label {
            visible: metricRowRoot.detail !== ""
            text: metricRowRoot.detail
            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
            color: Kirigami.Theme.disabledTextColor
            Layout.preferredWidth: Kirigami.Units.gridUnit * 4
        }
    }

    ColumnLayout {
        id: mainColumn
        anchors {
            fill: parent
            margins: Kirigami.Units.largeSpacing
        }
        spacing: Kirigami.Units.mediumSpacing

        // --- Header ---
        PlasmaExtras.Heading {
            text: "System Metrics"
            level: 3
            Layout.fillWidth: true
        }

        // --- Separator ---
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Kirigami.Theme.disabledTextColor
            opacity: 0.3
        }

        // --- CPU ---
        MetricRow {
            icon: "󰍛"
            label: "CPU"
            valueText: fullRoot.cpuUsage + "%"
            percentage: fullRoot.cpuUsage
        }

        // --- CPU Temp ---
        MetricRow {
            icon: ""
            label: "Temp"
            valueText: fullRoot.cpuTemp + "°C"
            percentage: Math.min(fullRoot.cpuTemp, 100)
            showBar: false
        }

        // --- GPU ---
        MetricRow {
            visible: fullRoot.gpuType !== "none"
            icon: "󰢮"
            label: "GPU"
            valueText: fullRoot.gpuUsage + "%"
            percentage: fullRoot.gpuUsage
            detail: fullRoot.gpuType.charAt(0).toUpperCase() + fullRoot.gpuType.slice(1)
        }

        // --- Separator ---
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Kirigami.Theme.disabledTextColor
            opacity: 0.15
        }

        // --- RAM ---
        MetricRow {
            icon: "󰘚"
            label: "RAM"
            valueText: fullRoot.ramUsage + "%"
            percentage: fullRoot.ramUsage
            detail: fullRoot.ramUsedGb + " / " + fullRoot.ramTotalGb + " GB"
        }

        // --- Swap ---
        MetricRow {
            visible: fullRoot.swapUsage > 0 || fullRoot.showSwap
            icon: ""
            label: "Swap"
            valueText: fullRoot.swapUsage + "%"
            percentage: fullRoot.swapUsage
        }

        // --- ZRAM ---
        MetricRow {
            visible: fullRoot.zramUsage > 0 || fullRoot.showZram
            icon: ""
            label: "ZRAM"
            valueText: fullRoot.zramUsage + "%"
            percentage: fullRoot.zramUsage
        }

        // --- Separator ---
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Kirigami.Theme.disabledTextColor
            opacity: 0.15
        }

        // --- Disk ---
        MetricRow {
            icon: "󰋊"
            label: "Disk"
            valueText: fullRoot.diskUsage + "%"
            percentage: fullRoot.diskUsage
            detail: fullRoot.diskUsed + " / " + fullRoot.diskTotal
        }

        // --- Separator ---
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Kirigami.Theme.disabledTextColor
            opacity: 0.15
        }

        // --- Network ---
        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            PlasmaComponents.Label {
                text: "󰛳"
                font.family: "Symbols Nerd Font Mono"
                font.pixelSize: Kirigami.Units.iconSizes.smallMedium
                color: Kirigami.Theme.textColor
                Layout.preferredWidth: Kirigami.Units.gridUnit * 1.5
                horizontalAlignment: Text.AlignHCenter
            }

            PlasmaComponents.Label {
                text: fullRoot.netIface
                font.pixelSize: Kirigami.Theme.defaultFont.pixelSize
                color: Kirigami.Theme.textColor
                Layout.preferredWidth: Kirigami.Units.gridUnit * 3
            }

            Item { Layout.fillWidth: true }

            ColumnLayout {
                spacing: 2

                RowLayout {
                    spacing: Kirigami.Units.smallSpacing
                    PlasmaComponents.Label {
                        text: "↓"
                        font.pixelSize: Kirigami.Theme.defaultFont.pixelSize
                        font.bold: true
                        color: Kirigami.Theme.positiveTextColor
                    }
                    PlasmaComponents.Label {
                        text: fullRoot.netRx
                        font.pixelSize: Kirigami.Theme.defaultFont.pixelSize
                        color: Kirigami.Theme.textColor
                    }
                }

                RowLayout {
                    spacing: Kirigami.Units.smallSpacing
                    PlasmaComponents.Label {
                        text: "↑"
                        font.pixelSize: Kirigami.Theme.defaultFont.pixelSize
                        font.bold: true
                        color: Kirigami.Theme.neutralTextColor
                    }
                    PlasmaComponents.Label {
                        text: fullRoot.netTx
                        font.pixelSize: Kirigami.Theme.defaultFont.pixelSize
                        color: Kirigami.Theme.textColor
                    }
                }
            }
        }
    }
}
