import QtQuick 2.0
import QtQuick.Layouts 1.3

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import "../code/utils.js" as Utils

Item {
    id: weatherViewRoot
    height: forecast.count > 0 ? 180 : 90
    Layout.minimumHeight: height
    Layout.preferredHeight: height

    QtObject {
        id: p

        property bool loading: false
        property bool ready: false

        // Data to be displayed
        property string location_header: ""
        property string location_subheader: ""
        property string station: ""

        property double temperature
        property int temperature_unit
        property string temperature_label: {
            if (temperature_unit == 6001)
                return '°C'
            if (temperature_unit == 6002)
                return '°F'

            print('Unknown temperature unit ', temperature_unit)
            return '°'
        }
    }

    ListModel {
        id: forecast
    }

    Component {
        id: component_contents
        GridLayout {
            columnSpacing: 0
            rowSpacing: 0
            columns: 4
            PlasmaExtras.Heading {
                id: location
                level: 2
                text: p.location_header

                Layout.columnSpan: p.current_temperature === '' ? 4 : 3
                Layout.fillWidth: true
            }

            PlasmaExtras.Heading {
                id: temperature

                visible: p.temperature != 0
                text: p.temperature.toFixed(1) + p.temperature_label

                Layout.rowSpan: 2
            }

            PlasmaExtras.Heading {
                id: country

                level: 5
                text: p.location_subheader

                Layout.columnSpan: p.current_temperature === '' ? 4 : 3
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.columnSpan: 4
                Layout.alignment: Qt.AlignHCenter
                spacing: 12

                Repeater {
                    model: forecast
                    delegate: ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        PlasmaComponents.Label {
                            text: model.when

                            Layout.alignment: Qt.AlignHCenter
                        }
                        PlasmaCore.IconItem {
                            source: model.icon

                            Layout.alignment: Qt.AlignHCenter
                            Layout.fillWidth: true
                        }
                        RowLayout {
                            spacing: 0

                            PlasmaComponents.Label {
                                text: {
                                    var str = ''
                                    if (model.temperature_max !== '')
                                        str += model.temperature_max + p.temperature_label
                                    else
                                        str += '-'
                                    return str
                                }
//                                 color: 'darkred'
                            }
                            PlasmaComponents.Label {
                                text: '/'
                            }
                            PlasmaComponents.Label {
                                text: {
                                    var str = ''
                                    if (model.temperature_min != '')
                                        str += model.temperature_min + p.temperature_label
                                    else
                                        str += '-'

                                    return str
                                }
//                                 color: 'blue'
                            }
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }
            }
        }
    }

    Component {
        id: component_status
        Item {
            PlasmaComponents.BusyIndicator {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: msg.top
                anchors.bottomMargin: 12

                visible: p.loading
            }

            PlasmaCore.IconItem {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: msg.top
                anchors.bottomMargin: 12

                source: 'weather-none'
                visible: !p.loading
            }

            PlasmaExtras.Heading {
                id: msg
                level: 4

                text: {
                    if (plasmoid.configuration.place === '')
                        return "Please configure your location."

                    if (p.loading)
                        return "Loading weather data of %1.".arg(
                                    plasmoid.configuration.place)

                    if (!p.ready)
                        return "There was an error, please check your internet connection."
                    else
                        return "All ok."
                }

                horizontalAlignment: Text.AlignHCenter

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 12
            }

            MouseArea {
                anchors.fill: parent
            }
        }
    }

    Loader {
        id: loader_contents

        sourceComponent: p.ready ? component_contents : component_status

        anchors.fill: parent
    }

    PlasmaCore.DataSource {
        id: weatherDataSource
        engine: "weather"
        interval: plasmoid.configuration.refresh_time
        property string place: plasmoid.configuration.place

        // HACK: The RegExp replace is to avoid issues with char encoding
        property string query: plasmoid.configuration.query.replace(new RegExp("[^0-9a-zA-Z\|\ \,\.;\\\/\+-:]","gm"), '?')

        onDataChanged: {
//            print("Loading results of: ", query)
            var queryData = data[query]

            if (!queryData || queryData['validate'] || queryData['Validate']) {
                p.loading = false
                return
            }

            Utils.parse_wheater(queryData)

            p.ready = true
            p.loading = false
        }

        onQueryChanged: updateSource()

        function updateSource() {
//            print('setting new query: ', query)
            p.loading = true
            p.ready = false

            // Clear previous sources
            for (var i in connectedSources)
                disconnectSource(connectedSources[i])

            weatherDataSource.connectSource(query)
        }
    }
}
