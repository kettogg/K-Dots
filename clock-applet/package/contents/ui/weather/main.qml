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

import QtQuick.Layouts 1.0

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

Item {
    id: root

    property string currentWeatherIconName: {
        var panelModel = plasmoid.nativeInterface.panelModel;
        return !panelModel.location ? "weather-none-available" : panelModel.currentConditionIcon;
    }

    Plasmoid.icon: currentWeatherIconName
    Plasmoid.toolTipMainText: {
        // workaround for now to ensure "Please Configure" tooltip
        // TODO: remove when configurationRequired works
        return plasmoid.nativeInterface.panelModel.location || i18nc("Shown when you have not set a weather provider", "Please Configure");
    }
    Plasmoid.toolTipSubText: {
        var panelModel = plasmoid.nativeInterface.panelModel;
        if (!panelModel.location) {
            return "";
        }
        if (panelModel.currentConditions && panelModel.currentTemperature) {
            return i18nc("%1 is the weather condition, %2 is the temperature,  both come from the weather provider",
                         "%1 %2", panelModel.currentConditions, panelModel.currentTemperature);
        }
        return panelModel.currentConditions || panelModel.currentTemperature || "";
    }

    Plasmoid.compactRepresentation: Component {
        MouseArea {
            id: compactRoot
            onClicked: plasmoid.expanded = !plasmoid.expanded

            PlasmaCore.IconItem {
                width: height
                height: compactRoot.height
                source: currentWeatherIconName
            }
        }
    }

    Plasmoid.fullRepresentation: Item {
        id: fullRoot
        Layout.minimumWidth: units.gridUnit * 12
        Layout.minimumHeight: units.gridUnit * 12
        Layout.preferredWidth: Layout.minimumWidth * 1.5
        Layout.preferredHeight: Layout.minimumHeight * 1.5

        TopPanel {
            id: panel
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                // matching round ends of bars behind data rows
                margins: units.smallSpacing
            }
            height: parent.height * 0.21
            model: plasmoid.nativeInterface.panelModel
        }

        PlasmaComponents.TabBar {
            id: tabBar
            anchors {
                top: panel.bottom
                topMargin: units.smallSpacing
                horizontalCenter: parent.horizontalCenter
            }

            visible: detailsView.model.length > 0

            PlasmaComponents.TabButton {
                text: plasmoid.nativeInterface.panelModel.totalDays
                tab: fiveDaysView
            }
            PlasmaComponents.TabButton {
                text: i18n("Details")
                tab: detailsView
            }
            PlasmaComponents.TabButton {
                text: i18n("Notices")
                visible: noticesView.visible
                onClicked: noticesView
            }
        }

        PlasmaComponents.TabGroup {
            id: mainTabGroup
            anchors {
                top: tabBar.visible ? tabBar.bottom : tabBar.top
                bottom: courtesyLabel.top
                left: parent.left
                right: parent.right
                topMargin: units.smallSpacing
                bottomMargin: units.smallSpacing
            }
            FiveDaysView {
                id: fiveDaysView
                anchors.fill: parent
                model: plasmoid.nativeInterface.fiveDaysModel
            }

            DetailsView {
                id: detailsView
                anchors.fill: parent
                model: plasmoid.nativeInterface.detailsModel
            }

            NoticesView {
                id: noticesView
                anchors.fill: parent
                model: plasmoid.nativeInterface.noticesModel
            }
        }

        PlasmaComponents.Label {
            id: courtesyLabel
            property string creditUrl: plasmoid.nativeInterface.panelModel.creditUrl
            anchors {
                bottom: parent.bottom
                right: parent.right
                left: parent.left
                // matching round ends of bars behind data rows
                rightMargin: units.smallSpacing
            }
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignRight
            font {
                pointSize: theme.smallestFont.pointSize
                underline: !!creditUrl
            }
            linkColor : color
            opacity: 0.6
            textFormat: Text.StyledText
            text: {
                var result = plasmoid.nativeInterface.panelModel.courtesy;
                if (creditUrl) {
                    result = "<a href=\"" + creditUrl + "\">" + result + "</a>";
                }
                return result;
            }
            onLinkActivated: Qt.openUrlExternally(link);
        }
    }
}
