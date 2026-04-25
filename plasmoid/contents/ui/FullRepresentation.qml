import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.plasmoid

Item {
    id: fullRoot

    // --- Properties bound from main.qml ---
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
    property bool showSwap: false
    property bool showZram: false
    readonly property color foregroundColor: "#ffffff"
    readonly property color secondaryForegroundColor: "#ffffff"
    readonly property color separatorColor: Qt.rgba(1, 1, 1, 0.22)
    readonly property color barTrackColor: Qt.rgba(1, 1, 1, 0.18)

    implicitWidth: Kirigami.Units.gridUnit * 18
    implicitHeight: mainColumn.implicitHeight + Kirigami.Units.largeSpacing * 2

    ColumnLayout {
        id: mainColumn

        spacing: Kirigami.Units.mediumSpacing

        anchors {
            fill: parent
            margins: Kirigami.Units.largeSpacing
        }

        // --- Header ---
        PlasmaExtras.Heading {
            text: "System Metrics"
            level: 3
            color: fullRoot.foregroundColor
            Layout.fillWidth: true
        }

        // --- Separator ---
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: fullRoot.separatorColor
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
            icon: ""
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
            color: fullRoot.separatorColor
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
            visible: fullRoot.hasSwap && (fullRoot.swapUsage > 0 || fullRoot.showSwap)
            icon: "󰟜"
            label: "Swap"
            valueText: fullRoot.swapUsage + "%"
            percentage: fullRoot.swapUsage
        }

        // --- ZRAM ---
        MetricRow {
            visible: fullRoot.hasZram && (fullRoot.zramUsage > 0 || fullRoot.showZram)
            icon: ""
            label: "ZRAM"
            valueText: fullRoot.zramUsage + "%"
            percentage: fullRoot.zramUsage
        }

        // --- Separator ---
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: fullRoot.separatorColor
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
            color: fullRoot.separatorColor
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
                color: fullRoot.foregroundColor
                Layout.preferredWidth: Kirigami.Units.gridUnit * 1.5
                horizontalAlignment: Text.AlignHCenter
            }

            PlasmaComponents.Label {
                text: fullRoot.netIface
                font.pixelSize: Kirigami.Theme.defaultFont.pixelSize
                color: fullRoot.foregroundColor
                Layout.preferredWidth: Kirigami.Units.gridUnit * 3
            }

            Item {
                Layout.fillWidth: true
            }

            ColumnLayout {
                spacing: 2

                RowLayout {
                    spacing: Kirigami.Units.smallSpacing

                    PlasmaComponents.Label {
                        text: "↓"
                        font.pixelSize: Kirigami.Theme.defaultFont.pixelSize
                        font.bold: true
                        color: fullRoot.foregroundColor
                    }

                    PlasmaComponents.Label {
                        text: fullRoot.netRx
                        font.pixelSize: Kirigami.Theme.defaultFont.pixelSize
                        color: fullRoot.foregroundColor
                    }

                }

                RowLayout {
                    spacing: Kirigami.Units.smallSpacing

                    PlasmaComponents.Label {
                        text: "↑"
                        font.pixelSize: Kirigami.Theme.defaultFont.pixelSize
                        font.bold: true
                        color: fullRoot.foregroundColor
                    }

                    PlasmaComponents.Label {
                        text: fullRoot.netTx
                        font.pixelSize: Kirigami.Theme.defaultFont.pixelSize
                        color: fullRoot.foregroundColor
                    }

                }

            }

        }

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
            color: fullRoot.foregroundColor
            Layout.preferredWidth: Kirigami.Units.gridUnit * 1.5
            horizontalAlignment: Text.AlignHCenter
        }

        // Label
        PlasmaComponents.Label {
            text: metricRowRoot.label
            font.pixelSize: Kirigami.Theme.defaultFont.pixelSize
            color: fullRoot.foregroundColor
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
                color: fullRoot.barTrackColor
                opacity: 0.4

                Rectangle {
                    width: parent.width * Math.min(metricRowRoot.percentage, 100) / 100
                    height: parent.height
                    radius: height / 2
                    color: fullRoot.foregroundColor

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
            color: fullRoot.foregroundColor
            Layout.preferredWidth: Kirigami.Units.gridUnit * 2.5
            horizontalAlignment: Text.AlignRight
        }

        // Detail text (optional)
        PlasmaComponents.Label {
            visible: metricRowRoot.detail !== ""
            text: metricRowRoot.detail
            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
            color: fullRoot.secondaryForegroundColor
            Layout.preferredWidth: Kirigami.Units.gridUnit * 4
        }

    }

}
