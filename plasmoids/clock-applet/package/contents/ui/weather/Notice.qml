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

import org.kde.plasma.components 2.0 as PlasmaComponents

Column {
    property alias model: repeater.model
    property alias title: title.text

    anchors.left: parent.left
    anchors.right: parent.right

    PlasmaComponents.Label {
        id: title
        font.bold: true
    }

    Repeater {
        id: repeater

        PlasmaComponents.Label {
            font.underline: true
            color: theme.linkColor
            text: modelData.description

            MouseArea {
                anchors.fill: parent
                onClicked: Qt.openUrlExternally(modelData.info);
            }
        }
    }
}
