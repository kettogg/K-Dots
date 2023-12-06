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

import org.kde.plasma.private.weather 1.0


ColumnLayout {
    id: generalConfigPage

    signal configurationChanged

    function saveConfig() {
        var config = {};

        config.temperatureUnitId =
            TemperatureUnitListModel.unitIdForListIndex(temperatureComboBox.currentIndex);
        config.pressureUnitId =
            PressureUnitListModel.unitIdForListIndex(pressureComboBox.currentIndex);
        config.windSpeedUnitId =
            WindSpeedUnitListModel.unitIdForListIndex(windSpeedComboBox.currentIndex);
        config.visibilityUnitId =
            VisibilityUnitListModel.unitIdForListIndex(visibilityComboBox.currentIndex);

        plasmoid.nativeInterface.saveConfig(config);
        plasmoid.nativeInterface.configChanged();
    }

    Component.onCompleted: {
        var config = plasmoid.nativeInterface.configValues();

        temperatureComboBox.currentIndex =
            TemperatureUnitListModel.listIndexForUnitId(config.temperatureUnitId);
        pressureComboBox.currentIndex =
            PressureUnitListModel.listIndexForUnitId(config.pressureUnitId);
        windSpeedComboBox.currentIndex =
            WindSpeedUnitListModel.listIndexForUnitId(config.windSpeedUnitId);
        visibilityComboBox.currentIndex =
            VisibilityUnitListModel.listIndexForUnitId(config.visibilityUnitId);
    }


    GridLayout {
        columns: 2

        QtControls.Label {
            Layout.row: 0
            Layout.column: 0
            Layout.alignment: Qt.AlignRight
            text: i18n("Temperature:")
        }

        QtControls.ComboBox {
            id: temperatureComboBox
            Layout.row: 0
            Layout.column: 1
            Layout.minimumWidth: units.gridUnit * 8
            model: TemperatureUnitListModel
            textRole: "display"
            onCurrentIndexChanged: generalConfigPage.configurationChanged();
        }

        QtControls.Label {
            Layout.row: 1
            Layout.column: 0
            Layout.alignment: Qt.AlignRight
            text: i18n("Pressure:")
        }

        QtControls.ComboBox {
            id: pressureComboBox
            Layout.row: 1
            Layout.column: 1
            Layout.minimumWidth: units.gridUnit * 8
            model: PressureUnitListModel
            textRole: "display"
            onCurrentIndexChanged: generalConfigPage.configurationChanged();
        }

        QtControls.Label {
            Layout.row: 2
            Layout.column: 0
            Layout.alignment: Qt.AlignRight
            text: i18n("Wind speed:")
        }

        QtControls.ComboBox {
            id: windSpeedComboBox
            Layout.row: 2
            Layout.column: 1
            Layout.minimumWidth: units.gridUnit * 8
            model: WindSpeedUnitListModel
            textRole: "display"
            onCurrentIndexChanged: generalConfigPage.configurationChanged();
        }

        QtControls.Label {
            Layout.row: 3
            Layout.column: 0
            Layout.alignment: Qt.AlignRight
            text: i18n("Visibility:")
        }

        QtControls.ComboBox {
            id: visibilityComboBox
            Layout.row: 3
            Layout.column: 1
            Layout.minimumWidth: units.gridUnit * 8
            model: VisibilityUnitListModel
            textRole: "display"
            onCurrentIndexChanged: generalConfigPage.configurationChanged();
        }
    }

    Item { // tighten layout
        Layout.fillHeight: true
    }
}
