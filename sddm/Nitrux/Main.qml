/***************************************************************************
* Copyright (c) 2015 Mikkel Oscar Lyderik <mikkeloscar@gmail.com>
*
* Permission is hereby granted, free of charge, to any person
* obtaining a copy of this software and associated documentation
* files (the "Software"), to deal in the Software without restriction,
* including without limitation the rights to use, copy, modify, merge,
* publish, distribute, sublicense, and/or sell copies of the Software,
* and to permit persons to whom the Software is furnished to do so,
* subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included
* in all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
* OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
* OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
* ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
* OR OTHER DEALINGS IN THE SOFTWARE.
*
***************************************************************************/

import QtQuick 2.12
import QtGraphicalEffects 1.0
import SddmComponents 2.0
import QtQuick.Layouts 1.3
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.components 3.0 as PlasmaComponents3
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 2.12

import "Components"

Rectangle {
    id: container

    LayoutMirroring.enabled: Qt.locale().textDirection == Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    property string avatarPath: ''
    property real faceSize: units.gridUnit * 10


    TextConstants { id: textConstants }

    Connections {
        target: sddm

        function onLoginSucceeded() {
        }

        function onLoginFailed(){
            errorMessage.text = textConstants.loginFailed
            password.text = ""
        }
    }


    Background {
        id: background
        anchors.fill: parent
        source: config.background
        fillMode: Image.PreserveAspectCrop
        onStatusChanged: {
            if (status == Image.Error && source != config.defaultBackground) {
                source = config.defaultBackground
            }
        }
    }

    GaussianBlur {
        anchors.fill: background
        source: background
        radius: 50
        samples: 101
    }

    ColorOverlay {
        anchors.fill: background
        source: background
        color: "#e2eef3"
        opacity: 0.7
    }

    Rectangle {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: 200
        height: 120
        color: "transparent"
        visible: primaryScreen

        Column {
            id: rebootColumn
            spacing: 5

            ImageButton {
                id: btnReboot
                anchors.horizontalCenter: parent.horizontalCenter
                width: 64
                source: "system-reboot.svg"

                //visible: sddm.canReboot

                onClicked: sddm.reboot()

                KeyNavigation.backtab: loginButton; KeyNavigation.tab: btnPoweroff
            }

            Text {
                text: "Reboot"
                color: "#424242"
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        Column {
            id: poweroffColumn
            spacing: 5
            anchors.right: parent.right

            ImageButton {
                id: btnPoweroff
                anchors.horizontalCenter: parent.horizontalCenter
                width: 64
                source: "system-shutdown.svg"

                //visible: sddm.canPowerOff

                onClicked: sddm.powerOff()

                KeyNavigation.backtab: btnReboot;
                KeyNavigation.tab: session
            }

            Text {
                text: "Shutdown"
                color: "#424242"
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    Rectangle {
        id: loginArea
        anchors.fill: parent
        color: "transparent"
        visible: primaryScreen


        Column {
            id: mainColumn
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -100
            spacing: 12

            Image {
                id: space1
                width: 100
                height: 100
                fillMode: Image.PreserveAspectFit
                source: "blank_space.svg"
            }

            Rectangle{
                width: faceSize
                height: faceSize
                anchors.horizontalCenter: parent.horizontalCenter
                color: "transparent"
                Image {
                    id: logo
                    sourceSize: Qt.size(faceSize, faceSize)
                    anchors.centerIn: parent
                    fillMode: Image.PreserveAspectFit
                    source: avatarPath
                    NumberAnimation {
                        id: animation
                        target: logo
                        property: "opacity"
                        from: 0
                        to: 1.0
                        duration: 750
                    }
                }

                Image {
                    sourceSize: Qt.size(faceSize, faceSize)
                    anchors.centerIn: parent
                    visible: (logo.status == Image.Error || logo.status == Image.Null)
                    fillMode: Image.PreserveAspectFit
                    source: 'logo.png'
                }
            }

            Text {
                id: statusText
                anchors.horizontalCenter: mainColumn.horizontalCenter
                anchors.bottomMargin: 12
                text: i18n("Hi there, Welcome back!")
            }

            TextBox {
                id: name
                width: 256
                height: 32
                text: rememberLastUser.checked ? userModel.lastUser : ""
                font.pixelSize: 12
                radius: 3
                color: "#f5f5f5"
                borderColor: "#c3c9d6"
                focusColor: "#00acc1"
                hoverColor: "#00ACC1"
                textColor: "#263238"

                KeyNavigation.tab: password
                
                onTextChanged: {
                    var localAvatarPath = ''
                    for (var row = 0; row < userModel.rowCount() ; row++){
                        for (var col = 0; col < userModel.columnCount() ; col++){
                            // 257  NameRole
                            // 260  IconRole
                            if(text === userModel.data(userModel.index(row,col),257)){
                                localAvatarPath = userModel.data(userModel.index(row,col),260)
                                if(!localAvatarPath.includes('/usr/share/sddm/')){
                                    avatarPath = localAvatarPath
                                    animation.start()
                                    return
                                }
                            }
                        }
                    }
                    if(avatarPath !== 'logo.png'){
                        avatarPath = 'logo.png'
                        animation.start()
                    }
                }

                Text {
                    id: userNotice
                    text: "Username"
                    color: "#90A4AE"
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        verticalCenter: parent.verticalCenter
                    }
                    visible: name.text == "";
                    font.pointSize: 9
                }
                
            }

            PasswordBox {
                id: password
                width: 256
                height: 32
                font.pixelSize: 12
                radius: 3
                color: "#F5F5F5"
                borderColor: "#c3c9d6"
                focusColor: "#00acc1"
                hoverColor: "#00ACC1"
                textColor: "#263238"
                focus: true
                
                Text {
                    id: passwordNotice
                    text: "Password"
                    color: "#90A4AE"
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        verticalCenter: parent.verticalCenter


                    }
                    visible: password.text == "";
                    font.pointSize: 9
                }
                
                Timer {
                    interval: 200
                    running: true
                    onTriggered: password.forceActiveFocus()
                }

                KeyNavigation.backtab: name; KeyNavigation.tab: loginButton

                onTextChanged:{
                    if(text.length === 1)
                        errorMessage.text = '-'
                }

                Keys.onPressed: {
                    if (event.key === Qt.Key_Return || event.key ===
                            Qt.Key_Enter) {
                        sddm.login(name.text, password.text, session.currentIndex)
                        event.accepted = true
                    }
                }
            }


            RowLayout {
                visible: false
                LayoutMirroring.enabled: true
                LayoutMirroring.childrenInherit: true
                anchors.horizontalCenter: parent.horizontalCenter

                CustomCheckBox {
                    id: rememberLastUser
                    height: 36
                    text: qsTr("Remember last User")

                    checked: config.rememberLastUser === "true"
                    onCheckedChanged: checked ? config.rememberLastUser = "true" : config.rememberLastUser = "false"


                    KeyNavigation.backtab: passwordNotice; KeyNavigation.tab: loginButton
                }

            }

            Button {
                id: loginButton
                text: textConstants.login
                anchors.horizontalCenter:  mainColumn.horizontalCenter
                width: 150
                height: 32

                KeyNavigation.backtab: password;
                KeyNavigation.tab: btnReboot


                background: Rectangle {
                    anchors.fill: loginButton
                    border.color: loginButton.hovered || loginButton.focus ?  "#00acc1" : "#dcdcdc"
                    border.width: 1
                    radius: 3
                    color: loginButton.down ? '#00acc1' : '#31363b'
                }

                contentItem: Text {
                    text: loginButton.text
                    color: loginButton.down ? '#f9f9fb' : '#f9f9fb'
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
                MouseArea {
                    hoverEnabled: true
                    anchors.fill: parent
                    cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: sddm.login(name.text, password.text, session.currentIndex)
                }
            }

            Text {
                id: errorMessage
                anchors.horizontalCenter: parent.horizontalCenter
                text: '-'
                font.pixelSize: 12
                color: "#31363b"
                // avoid layout movements
                opacity: errorMessage.text === '-' ? 0.01 : 1
            }
        }
    }

    //Action bar
    Rectangle{
        id: actionBarBackground
        anchors.fill: actionBar
        color: "#f9f9fb"
        opacity: 0.9
    }

    DropShadow {
        anchors.fill: actionBarBackground
        horizontalOffset: 0
        verticalOffset: 2
        radius: 8
        samples: 17
        color: "#707070"
        source: actionBarBackground
    }

    RowLayout {
        id: actionBar
        spacing: 8
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        Item {
            Layout.preferredWidth: 2
        }

        SessionButton {
            id: session
            KeyNavigation.backtab: btnPoweroff;
            KeyNavigation.tab: keyboardButton
        }

        KeyboardButton {
            id: keyboardButton
            KeyNavigation.backtab: session;
            KeyNavigation.tab: name
        }

        Item {
            Layout.fillWidth: true
        }

        InlineClock {
            color: "#31363b"
            font.pointSize: 12
        }
        Item {
            Layout.preferredWidth: 2
        }
    }
}
