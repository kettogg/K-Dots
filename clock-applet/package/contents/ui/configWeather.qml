import QtQml 2.2
import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

GridLayout {
    columns: 2
    columnSpacing: 10

    property alias cfg_place: queryField.place
    property alias cfg_query: queryField.query
    property alias cfg_show_weather: enabledCheckBox.checked
    property alias cfg_refresh_time: refreshTimeTextField.text

    PlasmaComponents.Label {
        Layout.leftMargin: 20
        text: i18n("Enabled")
    }

    PlasmaComponents.CheckBox {
        id: enabledCheckBox
    }

    PlasmaComponents.Label {
        Layout.leftMargin: 20
        text: i18n("Location")
    }

    PlasmaComponents.TextField {
        id: queryField
        Layout.minimumWidth: 300
        Layout.fillWidth: true

        property bool accepted: false
        property string query: ""
        property string place: ""

        text: place

        focus: true
        Keys.priority: Keys.BeforeItem
        Keys.onUpPressed: {
            suggestionsListView.currentIndex = Math.max(
                        0, suggestionsListView.currentIndex - 1)
            var new_text = placesSuggestionModel.get(
                        suggestionsListView.currentIndex).text
            if (new_text !== '')
                text = new_text
        }
        Keys.onDownPressed: {
            suggestionsListView.currentIndex = Math.min(
                        placesSuggestionModel.count - 1,
                        suggestionsListView.currentIndex + 1)
            var new_text = placesSuggestionModel.get(
                        suggestionsListView.currentIndex).text
            if (new_text !== '')
                text = new_text
        }

        Keys.onReleased: {
            if (event.text !== "" && text != weatherDataSource.query) {
                weatherDataSource.query = text
                queryField.accepted = false
            }
        }

        z: innerFrame.visible ? 100 : 0
        PlasmaCore.FrameSvgItem {
            id: innerFrame
            imagePath: "dialogs/background"
            enabledBorders: PlasmaCore.FrameSvg.NoBorder

            anchors.top: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            clip: true
            height: Math.min(6, placesSuggestionModel.count) * 32
            visible: (activeFocus || queryField.activeFocus)
                     && placesSuggestionModel.count > 0 && !queryField.accepted

            PlasmaExtras.ScrollArea {
                anchors.fill: parent

                ListView {
                    id: suggestionsListView

                    model: placesSuggestionModel
                    delegate: PlasmaComponents.ListItem {
                        height: 32
                        width: suggestionsListView.width
                        RowLayout {
                            anchors.fill: parent
                            Image {
                                Layout.leftMargin: 6
                                Layout.preferredHeight: 18
                                Layout.preferredWidth: 18
                                Layout.alignment: Qt.AlignVCenter

                                source: model.icon
                            }

                            PlasmaComponents.Label {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                Layout.leftMargin: 6

                                text: model.text
                            }
                        }

                        MouseArea {
                            anchors.fill: parent

                            hoverEnabled: true
                            onClicked: {
                                queryField.place = model.text
                                queryField.query = model.query
                                queryField.accepted = true

                                print("Place selected: ", cfg_query, cfg_place)
                            }
                            onEntered: suggestionsListView.currentIndex = index
                        }
                    }

                    highlight: PlasmaComponents.Highlight {
                    }
                }
            }
        }
    }

    PlasmaComponents.Label {
        text: i18n("Refresh time")

        Layout.leftMargin: 20
    }
    PlasmaComponents.TextField {
        id: refreshTimeTextField

        Layout.fillWidth: true
    }

    Item {
        Layout.fillHeight: true
        Layout.fillWidth: true
    }

    ListModel {
        id: placesSuggestionModel
    }

    PlasmaCore.DataSource {
        id: weatherDataSource
        engine: "weather"

        property string query: ""
        property string old_query: ""
        readonly property var ions: ["noaa", "bbcukmet", "wettercom", "envcan"]

        function extract_items(output, ion, icon) {
//            print('\n', output, '\n')

            var placeRegexp = /\|place\|(.*?)(\|extra\|(.*?))?(?=(\||$))/g
            var match = placeRegexp.exec(output)

            while (match != null) {
                var item = {
                    text: match[1],
                    query: ion + "|weather|" + match[1],
                    icon: icon
                }
                var extras

                if (ion === 'bbcukmet' || ion === 'wettercom') {
                    extras = match[3]
                } else
                    extras = match[2]

                if (extras && extras !== '|' && extras !== '')
                    item.query = item.query + '|' + extras

                placesSuggestionModel.append(item)
                match = placeRegexp.exec(output)
            }
        }
        onDataChanged: {
            placesSuggestionModel.clear()

            var bbcukmet_results = data['bbcukmet|validate|' + query]
            if (bbcukmet_results)
                extract_items(bbcukmet_results['validate'], 'bbcukmet',
                              "http://www.bbc.com/favicon.ico")

            var noaa_results = data['noaa|validate|' + query]
            if (noaa_results)
                extract_items(
                            noaa_results['validate'], 'noaa',
                            'http://www.noaa.gov/sites/all/themes/custom/noaa/images/noaa_logo_circle_bw_72x72.svg')

            var wettercom_results = data['wettercom|validate|' + query]
            if (wettercom_results)
                extract_items(wettercom_results['validate'], 'wettercom',
                              'http://www.wetter.com/favicon.ico')

            var envcan_results = data['envcan|validate|' + query]
            if (envcan_results)
                extract_items(envcan_results['validate'], 'envcan',
                              "https://weather.gc.ca/favicon.ico")
        }

        onQueryChanged: {
            if (query.length < 3)
                return

            // Connect new sources
            for (var i in ions) {
                disconnectSource(ions[i] + "|validate|" + old_query)
                weatherDataSource.connectSource(ions[i] + "|validate|" + query)
            }

            old_query = query
        }
    }
}
