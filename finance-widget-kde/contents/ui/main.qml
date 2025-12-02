import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as P5Support
import Qt.labs.platform as Labs

PlasmoidItem {
    id: root

    property var tickerData: []
    property bool loading: false
    property string errorMessage: ""
    property string tickers: plasmoid.configuration.tickers || "BTC-USD,ETH-USD,AAPL,PETR4.SA"
    property int updateInterval: (plasmoid.configuration.updateInterval || 5) * 60000
    property string scriptPath: ""
    property bool isExecuting: false

    width: Kirigami.Units.gridUnit * 20
    height: Kirigami.Units.gridUnit * 15

    Plasmoid.backgroundHints: PlasmaCore.Types.DefaultBackground | PlasmaCore.Types.ConfigurableBackground

    Timer {
        id: updateTimer
        interval: root.updateInterval
        running: true
        repeat: true
        triggeredOnStart: false
        onTriggered: {
            if (!isExecuting) {
                fetchData()
            }
        }
    }

    Component.onCompleted: {
        scriptPath = Labs.StandardPaths.writableLocation(Labs.StandardPaths.HomeLocation)
                    + "/.local/share/plasma/plasmoids/org.kde.plasma.financetracker/contents/code/finance.py"

        scriptPath = scriptPath.replace("file://", "")

        console.log("Script path:", scriptPath)
        console.log("Update interval:", updateInterval, "ms")
        fetchData()
    }

    P5Support.DataSource {
        id: executeSource
        engine: "executable"
        connectedSources: []

        onNewData: function(sourceName, data) {
            isExecuting = false
            loading = false
            console.log("Data received")

            var stdout = data["stdout"]
            var stderr = data["stderr"]

            if (stdout && stdout.trim() !== "") {
                try {
                    tickerData = JSON.parse(stdout)
                    errorMessage = ""
                    console.log("Loaded", tickerData.length, "tickers")
                } catch (e) {
                    errorMessage = "Erro ao processar: " + e.message
                    console.error("Parse error:", e)
                }
            } else {
                errorMessage = stderr || "Sem dados"
                console.error("Error:", stderr)
            }

            disconnectSource(sourceName)
        }
    }

    function fetchData() {
    if (isExecuting) {
        console.log("Already executing, skipping...")
        return
    }

    isExecuting = true
    loading = true
    errorMessage = ""

    var tickerArray = tickers.split(",").map(t => t.trim())

    var cmd = "python3 '" + scriptPath + "' " + tickerArray.join(" ")

    console.log("Executing:", cmd)

    executeSource.connectSource(cmd)
}


    compactRepresentation: Item {
        Layout.minimumWidth: Kirigami.Units.gridUnit * 8
        Layout.minimumHeight: Kirigami.Units.gridUnit * 2

        MouseArea {
            anchors.fill: parent
            onClicked: root.expanded = !root.expanded
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.smallSpacing
            spacing: Kirigami.Units.smallSpacing

            Kirigami.Icon {
                source: "office-chart-line"
                Layout.preferredWidth: Kirigami.Units.iconSizes.small
                Layout.preferredHeight: Kirigami.Units.iconSizes.small
            }

            Column {
                Layout.fillWidth: true
                spacing: 0

                PlasmaComponents.Label {
                    text: loading ? "Carregando..." :
                          errorMessage ? "Erro" :
                          tickerData.length > 0 ? tickerData[0].symbol : "Finance"
                    font.pointSize: Kirigami.Theme.smallFont.pointSize
                    font.bold: true
                }

                PlasmaComponents.Label {
                    visible: !loading && !errorMessage && tickerData.length > 0
                    text: tickerData.length > 0 ? "$" + tickerData[0].price.toFixed(2) : ""
                    font.pointSize: Kirigami.Theme.smallFont.pointSize
                    color: tickerData.length > 0 && tickerData[0].change >= 0 ?
                           Kirigami.Theme.positiveTextColor : Kirigami.Theme.negativeTextColor
                }
            }
        }
    }

    fullRepresentation: Item {
        Layout.preferredWidth: Kirigami.Units.gridUnit * 25
        Layout.preferredHeight: Kirigami.Units.gridUnit * 30

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.smallSpacing
            spacing: Kirigami.Units.smallSpacing

            RowLayout {
                Layout.fillWidth: true

                PlasmaComponents.Label {
                    text: "Finance Tracker"
                    font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.2
                    font.bold: true
                    Layout.fillWidth: true
                }

                PlasmaComponents.ToolButton {
                    icon.name: "view-refresh"
                    enabled: !isExecuting
                    onClicked: fetchData()

                    PlasmaComponents.ToolTip {
                        text: "Atualizar"
                    }
                }
            }

            Kirigami.Separator {
                Layout.fillWidth: true
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                PlasmaComponents.BusyIndicator {
                    anchors.centerIn: parent
                    visible: loading
                    running: loading
                }

                PlasmaComponents.Label {
                    anchors.centerIn: parent
                    visible: !loading && errorMessage !== ""
                    text: errorMessage
                    color: Kirigami.Theme.negativeTextColor
                    wrapMode: Text.WordWrap
                    width: parent.width - Kirigami.Units.largeSpacing * 2
                    horizontalAlignment: Text.AlignHCenter
                }

                ListView {
                    id: tickerListView
                    anchors.fill: parent
                    visible: !loading && errorMessage === "" && tickerData.length > 0
                    model: tickerData
                    spacing: Kirigami.Units.smallSpacing
                    clip: true

                    delegate: PlasmaComponents.ItemDelegate {
                        width: tickerListView.width

                        contentItem: ColumnLayout {
                            spacing: Kirigami.Units.smallSpacing

                            RowLayout {
                                Layout.fillWidth: true

                                PlasmaComponents.Label {
                                    text: modelData.symbol
                                    font.bold: true
                                    Layout.fillWidth: true
                                }

                                PlasmaComponents.Label {
                                    text: "$" + modelData.price.toFixed(2)
                                    font.bold: true
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true

                                PlasmaComponents.Label {
                                    text: modelData.name
                                    font.pointSize: Kirigami.Theme.smallFont.pointSize
                                    opacity: 0.7
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                PlasmaComponents.Label {
                                    text: (modelData.change >= 0 ? "+" : "")
                                          + modelData.change.toFixed(2) + "%"
                                    font.pointSize: Kirigami.Theme.smallFont.pointSize
                                    color: modelData.change >= 0 ?
                                           Kirigami.Theme.positiveTextColor :
                                           Kirigami.Theme.negativeTextColor
                                }
                            }

                            GridLayout {
                                Layout.fillWidth: true
                                columns: 2
                                rowSpacing: 2
                                columnSpacing: Kirigami.Units.largeSpacing

                                PlasmaComponents.Label {
                                    text: "7d:"
                                    font.pointSize: Kirigami.Theme.smallFont.pointSize
                                    opacity: 0.6
                                }
                                PlasmaComponents.Label {
                                    text: (modelData.change7d >= 0 ? "+" : "")
                                          + modelData.change7d.toFixed(2) + "%"
                                    font.pointSize: Kirigami.Theme.smallFont.pointSize
                                    color: modelData.change7d >= 0 ?
                                           Kirigami.Theme.positiveTextColor :
                                           Kirigami.Theme.negativeTextColor
                                }

                                PlasmaComponents.Label {
                                    text: "30d:"
                                    font.pointSize: Kirigami.Theme.smallFont.pointSize
                                    opacity: 0.6
                                }
                                PlasmaComponents.Label {
                                    text: (modelData.change30d >= 0 ? "+" : "")
                                          + modelData.change30d.toFixed(2) + "%"
                                    font.pointSize: Kirigami.Theme.smallFont.pointSize
                                    color: modelData.change30d >= 0 ?
                                           Kirigami.Theme.positiveTextColor :
                                           Kirigami.Theme.negativeTextColor
                                }
                            }

                            Kirigami.Separator {
                                Layout.fillWidth: true
                                Layout.topMargin: Kirigami.Units.smallSpacing
                            }
                        }
                    }
                }
            }

            PlasmaComponents.Label {
                Layout.fillWidth: true
                text: "Updated: " + Qt.formatTime(new Date(), "hh:mm:ss")
                      + " (refreshing in: " + (updateInterval / 60000) + " min)"
                font.pointSize: Kirigami.Theme.smallFont.pointSize
                opacity: 0.6
                horizontalAlignment: Text.AlignLeft
            }
        }
    }
}
