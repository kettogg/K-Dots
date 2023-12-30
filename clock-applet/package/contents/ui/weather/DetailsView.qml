/*
 * Copyright 2012  Luís Gabriel Lima <lampih@gmail.com>
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

import QtQuick 2.1

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

WeatherListView {
    id: root

    roundedRows: false

    delegate: Item {
        anchors.fill: parent

        Row {
            anchors.centerIn: parent
            height: parent.height
            width: childrenRect.width
            spacing: units.smallSpacing

            PlasmaCore.SvgItem {
                id: icon
                svg: windSvg
                elementId: rowData.icon
                height: naturalSize.height
                width: naturalSize.width
                visible: !!rowData.icon
            }

            PlasmaComponents.Label {
                anchors {
                    verticalCenter: parent.verticalCenter
                }
                text: rowData.text
            }
        }
    }

    PlasmaCore.Svg {
        id: windSvg
        imagePath: "weather/wind-arrows"
    }
}
