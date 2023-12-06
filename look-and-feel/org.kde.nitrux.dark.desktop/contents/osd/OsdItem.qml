/*
 * Copyright 2020 Uri Herrera <uri_herrera@nxos.org>
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
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtra
import QtQuick.Window 2.2

Row {
    property QtObject rootItem

    property int iconWidth: units.iconSizes.medium
    property int progressBarWidth: Screen.desktopAvailableWidth / 5

    height: iconWidth
    width: iconWidth + progressBarWidth

    PlasmaCore.IconItem {
        id: icon

        height: parent.height
        width: iconWidth

        source: rootItem.icon
    }

    PlasmaComponents.ProgressBar {
        id: progressBar

        width: progressBarWidth
        height: parent.height

        visible: rootItem.showingProgress
        minimumValue: 0
        maximumValue: 100

        value: Number(rootItem.osdValue)
    }

    PlasmaExtra.Heading {
        id: label

        width: progressBarWidth
        height: parent.height

        visible: !rootItem.showingProgress
        text: rootItem.showingProgress ? "" : (rootItem.osdValue ? rootItem.osdValue : "")
        horizontalAlignment: Text.AlignHCenter
        maximumLineCount: 1
        elide: Text.ElideLeft
        minimumPointSize: theme.defaultFont.pointSize
        fontSizeMode: Text.Fit
    }
}