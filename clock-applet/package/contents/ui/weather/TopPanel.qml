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
import org.kde.plasma.extras 2.0 as PlasmaExtras

PlasmaCore.FrameSvgItem {
    property var model

    imagePath: "widgets/frame"
    prefix: "plain"
    visible: !!model.location

    PlasmaCore.IconItem {
        id: iconItem
        source: model.currentConditionIcon
        height: parent.height
        width: height
    }

    PlasmaExtras.Heading {
        id: locationLabel
        anchors {
            top: parent.top
            left: parent.left
            right: tempLabel.visible ? forecastTempsLabel.left : parent.right
            topMargin: units.smallSpacing
            leftMargin: iconItem.width
        }
        font {
            bold: true
            pointSize: theme.defaultFont.pointSize * 1.4
        }
        text: model.location
        elide: Text.ElideRight
    }

    PlasmaComponents.Label {
        id: conditionLabel
        anchors {
            top: parent.top
            left: locationLabel.left
            topMargin: parent.height * 0.5
        }
        text: model.currentConditions
    }

    PlasmaComponents.Label {
        id: tempLabel
        anchors {
            right: parent.right
            top: locationLabel.top
            rightMargin: units.smallSpacing
        }
        font: locationLabel.font
        text: model.currentTemperature
    }

    PlasmaComponents.Label {
        id: forecastTempsLabel
        anchors {
            right: tempLabel.right
            top: conditionLabel.top
        }
        font.pointSize: theme.smallestFont.pointSize
        text: {
            var low = model.currentDayLowTemperature, high = model.currentDayHighTemperature;
            if (!!low && !!high) {
                return i18nc("High & Low temperature", "H: %1 L: %2", high, low);
            }
            if (!!low) {
                return i18nc("Low temperature", "Low: %1", low);
            }
            if (!!high) {
                return i18nc("High temperature", "High: %1", high);
            }
            return "";
        }
    }
}
