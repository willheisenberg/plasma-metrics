import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

MouseArea {
    id: compactRoot

    // --- Properties bound from main.qml ---
    property int cpuUsage: 0
    property int cpuTemp: 0
    property int gpuUsage: 0
    property string gpuType: "none"
    property int ramUsage: 0
    property int diskUsage: 0
    property string netRx: "0 B/s"
    property string netTx: "0 B/s"

    property bool showCpu: true
    property bool showGpu: true
    property bool showTemp: true
    property bool showRam: true
    property bool showDisk: true
    property bool showNetwork: true

    Layout.minimumWidth: metricsRow.implicitWidth + Kirigami.Units.smallSpacing * 2
    Layout.preferredWidth: metricsRow.implicitWidth + Kirigami.Units.smallSpacing * 2
    Layout.fillHeight: true

    hoverEnabled: true
    onClicked: Plasmoid.expanded = !Plasmoid.expanded

    // --- Color helper: green → yellow → red based on percentage ---
    function metricColor(value) {
        if (value < 50) {
            let ratio = value / 50.0
            let r = Math.round(ratio * 255)
            let g = 220
            let b = 50
            return Qt.rgba(r / 255, g / 255, b / 255, 1.0)
        } else {
            let ratio = (value - 50) / 50.0
            let r = 255
            let g = Math.round((1.0 - ratio) * 220)
            let b = 50
            return Qt.rgba(r / 255, g / 255, b / 255, 1.0)
        }
    }

    RowLayout {
        id: metricsRow
        anchors.fill: parent
        anchors.margins: Kirigami.Units.smallSpacing
        spacing: Kirigami.Units.mediumSpacing

        // --- CPU ---
        RowLayout {
            visible: compactRoot.showCpu
            spacing: 2
            PlasmaComponents.Label {
                text: "󰍛"
                font.family: "Symbols Nerd Font Mono"
                font.pixelSize: Kirigami.Units.iconSizes.small
                color: Kirigami.Theme.textColor
            }
            PlasmaComponents.Label {
                text: compactRoot.cpuUsage + "%"
                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                color: compactRoot.metricColor(compactRoot.cpuUsage)
            }
        }

        // --- GPU ---
        RowLayout {
            visible: compactRoot.showGpu && compactRoot.gpuType !== "none"
            spacing: 2
            PlasmaComponents.Label {
                text: "󰢮"
                font.family: "Symbols Nerd Font Mono"
                font.pixelSize: Kirigami.Units.iconSizes.small
                color: Kirigami.Theme.textColor
            }
            PlasmaComponents.Label {
                text: compactRoot.gpuUsage + "%"
                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                color: compactRoot.metricColor(compactRoot.gpuUsage)
            }
        }

        // --- Temperature ---
        RowLayout {
            visible: compactRoot.showTemp
            spacing: 2
            PlasmaComponents.Label {
                text: ""
                font.family: "Symbols Nerd Font Mono"
                font.pixelSize: Kirigami.Units.iconSizes.small
                color: Kirigami.Theme.textColor
            }
            PlasmaComponents.Label {
                text: compactRoot.cpuTemp + "°"
                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                color: compactRoot.metricColor(Math.min(compactRoot.cpuTemp, 100))
            }
        }

        // --- RAM ---
        RowLayout {
            visible: compactRoot.showRam
            spacing: 2
            PlasmaComponents.Label {
                text: "󰘚"
                font.family: "Symbols Nerd Font Mono"
                font.pixelSize: Kirigami.Units.iconSizes.small
                color: Kirigami.Theme.textColor
            }
            PlasmaComponents.Label {
                text: compactRoot.ramUsage + "%"
                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                color: compactRoot.metricColor(compactRoot.ramUsage)
            }
        }

        // --- Disk ---
        RowLayout {
            visible: compactRoot.showDisk
            spacing: 2
            PlasmaComponents.Label {
                text: "󰋊"
                font.family: "Symbols Nerd Font Mono"
                font.pixelSize: Kirigami.Units.iconSizes.small
                color: Kirigami.Theme.textColor
            }
            PlasmaComponents.Label {
                text: compactRoot.diskUsage + "%"
                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                color: compactRoot.metricColor(compactRoot.diskUsage)
            }
        }

        // --- Network ---
        RowLayout {
            visible: compactRoot.showNetwork
            spacing: 2
            PlasmaComponents.Label {
                text: "↓" + compactRoot.netRx
                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                color: Kirigami.Theme.positiveTextColor
            }
            PlasmaComponents.Label {
                text: "↑" + compactRoot.netTx
                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                color: Kirigami.Theme.neutralTextColor
            }
        }
    }
}
