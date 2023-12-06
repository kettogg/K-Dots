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

    delegate: Row {
        anchors.fill: parent

        Repeater {
            id: rowRepeater

            model: rowData

            Loader {
                height: rowIndex === 1 ? parent.height + root.spacing : parent.height
                width: parent.width / rowRepeater.count
                sourceComponent: rowIndex === 1 ? iconDelegate : textDelegate
                onLoaded: {
                    if (rowIndex === 1) {
                        var values = modelData.split("|");
                        item.source = values[0];
                        item.toolTip = values[1];
                    } else {
                        var txt = modelData;
                        if (txt.indexOf("nt") !== -1) {
                            txt = txt.replace(" nt", "");
                        }

                        item.text = txt;
                    }

                    if (rowIndex === 0) {
                        item.font.bold = true;
                    }
                }
            }
        }
    }

    Component {
        id: textDelegate

        PlasmaComponents.Label {
            function checkTitle(txt) {
                return txt.indexOf("ight") !== -1 || txt.indexOf("nite") !== -1;
            }

            // resetting the default height set by PlasmaComponents.Label,
            // which would result in first item in row with bad vertical position
            height: undefined
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            opacity: font.bold && checkTitle(text) ? 0.6 : 1
        }
    }

    Component {
        id: iconDelegate

        PlasmaCore.IconItem {
            property alias toolTip: iconToolTip.mainText
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -root.spacing/2

            PlasmaCore.ToolTipArea {
                id: iconToolTip
                anchors.fill: parent
            }
        }
    }
}
