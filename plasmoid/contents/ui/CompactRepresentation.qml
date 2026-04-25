import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasmoid

MouseArea {
    id: compactRoot

    // --- Properties bound from main.qml ---
    property int cpuUsage: 0
    property int cpuTemp: 0
    property int gpuUsage: 0
    property string gpuType: "none"
    property int ramUsage: 0
    property bool hasSwap: false
    property int swapUsage: 0
    property bool hasZram: false
    property int zramUsage: 0
    property int diskUsage: 0
    property string netRx: "0 B/s"
    property string netTx: "0 B/s"
    property int iconSize: 16
    property int textSize: 12
    property int iconTextSpacing: 2
    property int metricSpacing: 6
    property bool showCpu: true
    property bool showGpu: true
    property bool showTemp: true
    property bool showRam: true
    property bool showSwap: true
    property bool showZram: true
    property bool showDisk: true
    property bool showNetwork: true
    readonly property color foregroundColor: "#ffffff"

    Layout.minimumWidth: metricsRow.implicitWidth + Kirigami.Units.smallSpacing * 2
    Layout.preferredWidth: metricsRow.implicitWidth + Kirigami.Units.smallSpacing * 2
    Layout.fillHeight: true
    hoverEnabled: true
    onClicked: Plasmoid.expanded = !Plasmoid.expanded

    RowLayout {
        id: metricsRow

        anchors.fill: parent
        anchors.margins: Kirigami.Units.smallSpacing
        spacing: compactRoot.metricSpacing

        // --- CPU ---
        RowLayout {
            visible: compactRoot.showCpu
            spacing: compactRoot.iconTextSpacing

            PlasmaComponents.Label {
                text: "󰍛"
                font.family: "Symbols Nerd Font Mono"
                font.pixelSize: compactRoot.iconSize
                color: compactRoot.foregroundColor
            }

            PlasmaComponents.Label {
                text: compactRoot.cpuUsage + "%"
                font.pixelSize: compactRoot.textSize
                color: compactRoot.foregroundColor
            }

        }

        // --- GPU ---
        RowLayout {
            visible: compactRoot.showGpu && compactRoot.gpuType !== "none"
            spacing: compactRoot.iconTextSpacing

            PlasmaComponents.Label {
                text: "󰢮"
                font.family: "Symbols Nerd Font Mono"
                font.pixelSize: compactRoot.iconSize
                color: compactRoot.foregroundColor
            }

            PlasmaComponents.Label {
                text: compactRoot.gpuUsage + "%"
                font.pixelSize: compactRoot.textSize
                color: compactRoot.foregroundColor
            }

        }

        // --- Temperature ---
        RowLayout {
            visible: compactRoot.showTemp
            spacing: compactRoot.iconTextSpacing

            PlasmaComponents.Label {
                text: ""
                font.family: "Symbols Nerd Font Mono"
                font.pixelSize: compactRoot.iconSize
                color: compactRoot.foregroundColor
            }

            PlasmaComponents.Label {
                text: compactRoot.cpuTemp + "°"
                font.pixelSize: compactRoot.textSize
                color: compactRoot.foregroundColor
            }

        }

        // --- RAM ---
        RowLayout {
            visible: compactRoot.showRam
            spacing: compactRoot.iconTextSpacing

            PlasmaComponents.Label {
                text: "󰘚"
                font.family: "Symbols Nerd Font Mono"
                font.pixelSize: compactRoot.iconSize
                color: compactRoot.foregroundColor
            }

            PlasmaComponents.Label {
                text: compactRoot.ramUsage + "%"
                font.pixelSize: compactRoot.textSize
                color: compactRoot.foregroundColor
            }

        }

        // --- ZRAM ---
        RowLayout {
            visible: compactRoot.showZram && compactRoot.hasZram
            spacing: compactRoot.iconTextSpacing

            PlasmaComponents.Label {
                text: ""
                font.family: "Symbols Nerd Font Mono"
                font.pixelSize: compactRoot.iconSize
                color: compactRoot.foregroundColor
            }

            PlasmaComponents.Label {
                text: compactRoot.zramUsage + "%"
                font.pixelSize: compactRoot.textSize
                color: compactRoot.foregroundColor
            }

        }

        // --- Swap ---
        RowLayout {
            visible: compactRoot.showSwap && compactRoot.hasSwap
            spacing: compactRoot.iconTextSpacing

            PlasmaComponents.Label {
                text: "󰟜"
                font.family: "Symbols Nerd Font Mono"
                font.pixelSize: compactRoot.iconSize
                color: compactRoot.foregroundColor
            }

            PlasmaComponents.Label {
                text: compactRoot.swapUsage + "%"
                font.pixelSize: compactRoot.textSize
                color: compactRoot.foregroundColor
            }

        }

        // --- Disk ---
        RowLayout {
            visible: compactRoot.showDisk
            spacing: compactRoot.iconTextSpacing

            PlasmaComponents.Label {
                text: "󰋊"
                font.family: "Symbols Nerd Font Mono"
                font.pixelSize: compactRoot.iconSize
                color: compactRoot.foregroundColor
            }

            PlasmaComponents.Label {
                text: compactRoot.diskUsage + "%"
                font.pixelSize: compactRoot.textSize
                color: compactRoot.foregroundColor
            }

        }

        // --- Network ---
        RowLayout {
            visible: compactRoot.showNetwork
            spacing: compactRoot.iconTextSpacing

            PlasmaComponents.Label {
                text: "↓" + compactRoot.netRx
                font.pixelSize: compactRoot.textSize
                color: compactRoot.foregroundColor
            }

            PlasmaComponents.Label {
                text: "↑" + compactRoot.netTx
                font.pixelSize: compactRoot.textSize
                color: compactRoot.foregroundColor
            }

        }

    }

}
