/*
    SPDX-FileCopyrightText: 2014 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2014 David Edmundson <davidedmundson@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.0
import QtQuick.Controls.Styles 1.1 as QtQuickControlStyle
import QtQuick.Layouts 1.1
import QtQuick.Controls.Private 1.0 as QtQuickControlsPrivate

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.components 2.0 as PlasmaComponents

QtQuickControlStyle.ButtonStyle {
    id: style

    property int minimumWidth
    property int minimumHeight
    property bool flat: control.flat !== undefined ? control.flat : !(control.checkable && control.checked)
    property bool controlHovered: control.hovered && !(QtQuickControlsPrivate.Settings.hasTouchScreen && QtQuickControlsPrivate.Settings.isMobile) || control.focus

    label: Item {
        //wrapper is needed as we are adjusting the preferredHeight of the layout from the default
        //and the implicitHeight is implicitly read only
        implicitHeight: buttonContent.Layout.preferredHeight
        implicitWidth: buttonContent.implicitWidth
        RowLayout {
            id: buttonContent
            anchors.fill: parent
            spacing: PlasmaCore.Units.smallSpacing

            Layout.preferredHeight: Math.max(PlasmaCore.Units.iconSizes.small, label.implicitHeight)

            property real minimumWidth: Layout.minimumWidth + style.padding.left + style.padding.right
            onMinimumWidthChanged: {
                if (control.minimumWidth !== undefined) {
                    style.minimumWidth = minimumWidth;
                    control.minimumWidth = minimumWidth;
                }
            }

            property real minimumHeight: Layout.preferredHeight + style.padding.top + style.padding.bottom
            onMinimumHeightChanged: {
                if (control.minimumHeight !== undefined) {
                    style.minimumHeight = minimumHeight;
                    control.minimumHeight = minimumHeight;
                }
            }

            PlasmaCore.IconItem {
                id: icon
                source: control.iconName || control.iconSource
                implicitHeight: label.implicitHeight
                implicitWidth: implicitHeight
                Layout.minimumWidth: valid ? parent.height: 0
                Layout.maximumWidth: Layout.minimumWidth
                visible: valid
                Layout.minimumHeight: Layout.minimumWidth
                Layout.maximumHeight: Layout.minimumWidth
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                active: style.controlHovered
                colorGroup: !flat ? PlasmaCore.Theme.ButtonColorGroup : PlasmaCore.ColorScope.colorGroup
            }

            //NOTE: this is used only to check elements existence
            PlasmaCore.FrameSvgItem {
                id: buttonsurfaceChecker
                visible: false
                imagePath: "widgets/button"
                prefix: style.flat ? ["toolbutton-hover", "normal"] : "normal"
            }

            PlasmaComponents.Label {
                id: label
                Layout.minimumWidth: implicitWidth
                Layout.fillHeight: true
                height: undefined
                //Note: comment text
                //text: Util.stylizeEscapedMnemonics(Util.toHtmlEscaped(control.text))
                text: control.text
                textFormat: Text.StyledText
                font: control.font || PlasmaCore.Theme.defaultFont
                visible: control.text != ""
                Layout.fillWidth: true
                color: controlHovered ?  '#f9f9fb' : '#31363b'
                horizontalAlignment: icon.valid ? Text.AlignLeft : Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            Item {
                Layout.preferredWidth: 6
            }

            Image {
                sourceSize: Qt.size(PlasmaCore.Units.iconSizes.small/2,PlasmaCore.Units.iconSizes.small/2)
                fillMode: Image.PreserveAspectFit
                source: control.focus || control.hovered ? 'angle-down-hover.svg' : 'angle-down.svg'
            }
        }
    }

    background: Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        color: controlHovered ?  '#26c6da' : "transparent"
        radius: 3
        border.color: '#00acc1'
        border.width: controlHovered ?  1: 0
    }
}
