import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasmoid

Item {
    id: compactRoot

    // --- Properties bound from main.qml ---
    property PlasmoidItem plasmoidItem
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
    readonly property int panelPadding: Kirigami.Units.smallSpacing

    implicitHeight: metricsRow.implicitHeight + compactRoot.panelPadding * 2
    Layout.minimumWidth: metricsRow.implicitWidth + compactRoot.panelPadding * 2
    Layout.preferredWidth: metricsRow.implicitWidth + compactRoot.panelPadding * 2
    Layout.minimumHeight: compactRoot.implicitHeight
    Layout.fillHeight: true

    RowLayout {
        id: metricsRow

        anchors.centerIn: parent
        spacing: compactRoot.metricSpacing

        // --- CPU ---
        RowLayout {
            visible: compactRoot.showCpu
            spacing: compactRoot.iconTextSpacing
            Layout.alignment: Qt.AlignVCenter

            PlasmaComponents.Label {
                text: "󰍛"
                font.family: "Symbols Nerd Font Mono"
                font.pixelSize: compactRoot.iconSize
                color: compactRoot.foregroundColor
                Layout.alignment: Qt.AlignVCenter
            }

            PlasmaComponents.Label {
                text: compactRoot.cpuUsage + "%"
                font.pixelSize: compactRoot.textSize
                color: compactRoot.foregroundColor
                Layout.alignment: Qt.AlignVCenter
            }

        }

        // --- GPU ---
        RowLayout {
            visible: compactRoot.showGpu && compactRoot.gpuType !== "none"
            spacing: compactRoot.iconTextSpacing
            Layout.alignment: Qt.AlignVCenter

            PlasmaComponents.Label {
                text: "󰢮"
                font.family: "Symbols Nerd Font Mono"
                font.pixelSize: compactRoot.iconSize
                color: compactRoot.foregroundColor
                Layout.alignment: Qt.AlignVCenter
            }

            PlasmaComponents.Label {
                text: compactRoot.gpuUsage + "%"
                font.pixelSize: compactRoot.textSize
                color: compactRoot.foregroundColor
                Layout.alignment: Qt.AlignVCenter
            }

        }

        // --- Temperature ---
        RowLayout {
            visible: compactRoot.showTemp
            spacing: compactRoot.iconTextSpacing
            Layout.alignment: Qt.AlignVCenter

            PlasmaComponents.Label {
                text: ""
                font.family: "Symbols Nerd Font Mono"
                font.pixelSize: compactRoot.iconSize
                color: compactRoot.foregroundColor
                Layout.alignment: Qt.AlignVCenter
            }

            PlasmaComponents.Label {
                text: compactRoot.cpuTemp + "°"
                font.pixelSize: compactRoot.textSize
                color: compactRoot.foregroundColor
                Layout.alignment: Qt.AlignVCenter
            }

        }

        // --- RAM ---
        RowLayout {
            visible: compactRoot.showRam
            spacing: compactRoot.iconTextSpacing
            Layout.alignment: Qt.AlignVCenter

            PlasmaComponents.Label {
                text: "󰘚"
                font.family: "Symbols Nerd Font Mono"
                font.pixelSize: compactRoot.iconSize
                color: compactRoot.foregroundColor
                Layout.alignment: Qt.AlignVCenter
            }

            PlasmaComponents.Label {
                text: compactRoot.ramUsage + "%"
                font.pixelSize: compactRoot.textSize
                color: compactRoot.foregroundColor
                Layout.alignment: Qt.AlignVCenter
            }

        }

        // --- ZRAM ---
        RowLayout {
            visible: compactRoot.showZram && compactRoot.hasZram
            spacing: compactRoot.iconTextSpacing
            Layout.alignment: Qt.AlignVCenter

            PlasmaComponents.Label {
                text: ""
                font.family: "Symbols Nerd Font Mono"
                font.pixelSize: compactRoot.iconSize
                color: compactRoot.foregroundColor
                Layout.alignment: Qt.AlignVCenter
            }

            PlasmaComponents.Label {
                text: compactRoot.zramUsage + "%"
                font.pixelSize: compactRoot.textSize
                color: compactRoot.foregroundColor
                Layout.alignment: Qt.AlignVCenter
            }

        }

        // --- Swap ---
        RowLayout {
            visible: compactRoot.showSwap && compactRoot.hasSwap
            spacing: compactRoot.iconTextSpacing
            Layout.alignment: Qt.AlignVCenter

            PlasmaComponents.Label {
                text: "󰟜"
                font.family: "Symbols Nerd Font Mono"
                font.pixelSize: compactRoot.iconSize
                color: compactRoot.foregroundColor
                Layout.alignment: Qt.AlignVCenter
            }

            PlasmaComponents.Label {
                text: compactRoot.swapUsage + "%"
                font.pixelSize: compactRoot.textSize
                color: compactRoot.foregroundColor
                Layout.alignment: Qt.AlignVCenter
            }

        }

        // --- Disk ---
        RowLayout {
            visible: compactRoot.showDisk
            spacing: compactRoot.iconTextSpacing
            Layout.alignment: Qt.AlignVCenter

            PlasmaComponents.Label {
                text: "󰋊"
                font.family: "Symbols Nerd Font Mono"
                font.pixelSize: compactRoot.iconSize
                color: compactRoot.foregroundColor
                Layout.alignment: Qt.AlignVCenter
            }

            PlasmaComponents.Label {
                text: compactRoot.diskUsage + "%"
                font.pixelSize: compactRoot.textSize
                color: compactRoot.foregroundColor
                Layout.alignment: Qt.AlignVCenter
            }

        }

        // --- Network ---
        RowLayout {
            visible: compactRoot.showNetwork
            spacing: compactRoot.iconTextSpacing
            Layout.alignment: Qt.AlignVCenter

            PlasmaComponents.Label {
                text: "↓" + compactRoot.netRx
                font.pixelSize: compactRoot.textSize
                color: compactRoot.foregroundColor
                Layout.alignment: Qt.AlignVCenter
            }

            PlasmaComponents.Label {
                text: "↑" + compactRoot.netTx
                font.pixelSize: compactRoot.textSize
                color: compactRoot.foregroundColor
                Layout.alignment: Qt.AlignVCenter
            }

        }

    }

    MouseArea {
        id: clickArea

        property bool wasExpanded: false

        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPressed: wasExpanded = compactRoot.plasmoidItem ? compactRoot.plasmoidItem.expanded : false
        onClicked: {
            if (compactRoot.plasmoidItem)
                compactRoot.plasmoidItem.expanded = !clickArea.wasExpanded;
        }
    }

}
