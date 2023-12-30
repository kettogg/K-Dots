/*
 * Copyright 2016  Friedrich W. H. Kossebau <kossebau@kde.org>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import QtQuick.Controls 1.0 as QtControls
import QtQuick.Layouts 1.0

import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.plasma.private.weather 1.0


ColumnLayout {
    id: generalConfigPage

    signal configurationChanged

    function saveConfig() {
        var config = {};

        // only pick a new source if there is one selected in the locationListView
        if (locationListView.rowCount && locationListView.currentRow !== -1) {
            config.source = locationListModel.valueForListIndex(locationListView.currentRow);
        }

        config.updateInterval = updateIntervalSpin.value;

        plasmoid.nativeInterface.saveConfig(config);
        plasmoid.nativeInterface.configChanged();
    }

    function searchLocation() {
        // avoid automatic selection once model is refilled
        locationListView.currentRow = -1;
        locationListView.selection.clear();
        noSearchResultReport.visible = false;

        locationListModel.searchLocations(searchStringEdit.text);
    }

    function handleLocationSearchDone(success, searchString) {
        if (!success) {
            noSearchResultReport.text = i18n("No weather stations found for '%1'", searchString);
            noSearchResultReport.visible = true;
        }
    }

    Component.onCompleted: {
        var config = plasmoid.nativeInterface.configValues();

        var source;
        var sourceDetails = config.source.split('|');
        if (sourceDetails.length > 2) {
            source = i18nc("A weather station location and the weather service it comes from",
                           "%1 (%2)", sourceDetails[2], sourceDetails[0]);
        } else {
            source = "";
        }
        locationDisplay.setLocation(source);

        updateIntervalSpin.value = config.updateInterval;
    }

    LocationListModel {
        id: locationListModel
        onLocationSearchDone: handleLocationSearchDone(success, searchString);
    }

    GridLayout {
        columns: 2

        QtControls.Label {
            Layout.row: 0
            Layout.column: 0
            Layout.alignment: Qt.AlignRight
            text: i18n("Location:")
        }

        QtControls.Label {
            id: locationDisplay
            Layout.row: 0
            Layout.column: 1
            Layout.fillWidth: true
            elide: Text.ElideRight

            function setLocation(location) {
                locationDisplay.text = location || "-";
            }
        }

        RowLayout {
            Layout.row: 1
            Layout.column: 1
            Layout.fillWidth: true

            QtControls.TextField {
                id: searchStringEdit
                Layout.fillWidth: true
            }

            Item {
                Layout.preferredHeight: Math.max(searchButton.height, searchStringEdit.height)
                Layout.preferredWidth: Layout.preferredHeight

                PlasmaComponents.BusyIndicator {
                    id: busy
                    anchors.fill: parent
                    visible: locationListModel.validatingInput
                }
            }

            QtControls.Button {
                id: searchButton
                text: i18n("Search")
                enabled: !!searchStringEdit.text
                onClicked: searchLocation();
            }
        }

        QtControls.TableView {
            id: locationListView
            Layout.row: 2
            Layout.column: 1
            Layout.fillWidth: true
            Layout.fillHeight: true
            headerVisible: false
            model: locationListModel
            onActivated: {
                if (row !== -1) {
                    locationDisplay.setLocation(locationListModel.nameForListIndex(row));
                    generalConfigPage.configurationChanged();
                }
            }

            QtControls.TableViewColumn {
                id: locationListViewStationColumn
                movable: false
                resizable: false
                role: "display"
            }

            QtControls.Label {
                id: noSearchResultReport
                anchors.centerIn: parent
                visible: false
            }
        }

        QtControls.Label {
            Layout.row: 3
            Layout.column: 0
            Layout.alignment: Qt.AlignRight
            text: i18n("Update every:")
        }
        QtControls.SpinBox {
            id: updateIntervalSpin
            Layout.row: 3
            Layout.column: 1
            Layout.minimumWidth: units.gridUnit * 8
            suffix: i18n(" min")
            stepSize: 5
            minimumValue: 30
            maximumValue: 3600
            onValueChanged: generalConfigPage.configurationChanged();
        }
    }
}
