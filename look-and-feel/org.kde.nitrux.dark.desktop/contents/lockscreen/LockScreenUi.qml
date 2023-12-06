import QtQuick 2.5
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0

import QtQuick.Layouts 1.1

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.private.sessions 2.0
import "../components"

Rectangle {
    id: lockScreenRoot

    //colorGroup: PlasmaCore.Theme.ComplementaryColorGroup

    color: "transparent"

    FastBlur {
        anchors.fill: parent
        source: wallpaper
        radius: 50
    }

    Rectangle{
        anchors.fill: parent
        color: "#000000"
        opacity: 0.7
    }

    Connections {
        target: authenticator
        onFailed: {
            root.notification = i18nd("plasma_lookandfeel_org.kde.lookandfeel",
                                      "Unlocking failed")
        }
        onGraceLockedChanged: {
            if (!authenticator.graceLocked) {
                root.notification = ""
                root.clearPassword()
            }
        }
        onMessage: {
            root.notification = msg
        }
        onError: {
            root.notification = err
        }
    }

    SessionsModel {
        id: sessionsModel
        showNewSessionEntry: true
    }

    PlasmaCore.DataSource {
        id: keystateSource
        engine: "keystate"
        connectedSources: "Caps Lock"
    }


    Rectangle {
        id: actionBar
        anchors.top: parent.top;
        color: "#2b2c31"
        opacity: 1.0
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width; height: 32


        PlasmaComponents3.ToolButton {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: i18ndc("plasma_lookandfeel_org.kde.lookandfeel", "Button to show/hide virtual keyboard", "Virtual Keyboard")
            // icon.name: inputPanel.keyboardActive ? "input-keyboard-virtual-on" : "input-keyboard-virtual-off"
            onClicked: inputPanel.showHide()
            visible: inputPanel.status == Loader.Ready
        }

        // Clock
        Row {
            height: parent.height
            anchors.right: parent.right
            anchors.margins: 9
            spacing: 5

            InlineClock {
                color: "#F5F5F5"
                font.pointSize: 12
                font.weight: Font.Bold
            }
        }
        
        DropShadow {
            anchors.fill: actionBar
            horizontalOffset: 0
            verticalOffset: 1
            radius: 8
            samples: 17
            color: "#101010"
            cached: true
            source: actionBar
        }
    }
    
    // Image {
    //     source: "blur.png"
    //     anchors.centerIn: parent
    //     width:  parent.width / 3
    //     height: width
    //     opacity: 0.7
    // }

    Clock {
        id: clock
        anchors.bottom: parent.verticalCenter
        anchors.bottomMargin: units.gridUnit * - 1
        anchors.horizontalCenter: parent.horizontalCenter
    }

    ColumnLayout {
        id: mainBlock
        spacing: 18
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: clock.bottom
        anchors.topMargin: 18

        property bool locked: true


        Loader {
            id: passwordAreaLoader
            Layout.preferredWidth: 200
            Layout.alignment: Qt.AlignHCenter
            sourceComponent: mainBlock.locked ? undefined : passwordArea
            height: 0;
            clip: true

            NumberAnimation on height {
                id: showPasswordArea
                from: 0
                to: loginButton.height
                // duration: 500
            }
        }

        PlasmaCore.ColorScope {
            Layout.alignment: Qt.AlignHCenter
            implicitHeight: loginButton.implicitHeight
            implicitWidth: loginButton.implicitWidth

            colorGroup: PlasmaCore.Theme.ComplementaryColorGroup


            PlasmaComponents.Button {
                id: loginButton
                focus: true
                text: !authenticator.graceLocked ? i18nd(
                                                       "plasma_lookandfeel_org.kde.lookandfeel",
                                                       "Unlock") : i18nd(
                                                       "plasma_lookandfeel_org.kde.lookandfeel",
                                                       "Authenticating...")
                enabled: !authenticator.graceLocked
                onClicked: {
                    if (mainBlock.locked) {
                        showPasswordArea.start()
                        mainBlock.locked = false
                        passwordAreaLoader.item.forceActiveFocus()
                    } else
                        authenticator.tryUnlock(passwordAreaLoader.item.password)
                }

                Keys.onPressed: {
                    if (mainBlock.locked) {
                        showPasswordArea.start()
                        mainBlock.locked = false
                        root.clearPassword()
                    }
                }
            }
        }


        Loader {
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            Layout.preferredHeight: item ? item.implicitHeight : 0
            active: config.showMediaControls
            source: "MediaControls.qml"
        }
    }

        Loader {
            id: inputPanel
            state: "hidden"
            readonly property bool keyboardActive: item ? item.active : false
            Layout.fillWidth: true
            function showHide() {
                state = state == "hidden" ? "visible" : "hidden";
            }
            Component.onCompleted: inputPanel.source = "../components/VirtualKeyboard.qml"

            onKeyboardActiveChanged: {
                if (keyboardActive) {
                    state = "visible";
                    // Otherwise the password field loses focus and virtual keyboard
                    // keystrokes get eaten
                    //mainBlock.mainPasswordBox.forceActiveFocus();
                    if (mainBlock.locked) {
                        showPasswordArea.start()
                        mainBlock.locked = false
                        root.clearPassword()
                    }else{
                        root.clearPassword()
                    }
                } else {
                    state = "hidden";
                }
            }

            states: [
                State {
                    name: "visible"
                    PropertyChanges {
                        target: mainBlock
                        y: 0 // Math.min(0, lockScreenRoot.height - inputPanel.height - mainBlock.visibleBoundary)
                    }
                    PropertyChanges {
                        target: inputPanel
                        y: lockScreenRoot.height - inputPanel.height
                    }
                },
                State {
                    name: "hidden"
                    PropertyChanges {
                        target: mainBlock
                        y: 0
                    }
                    PropertyChanges {
                        target: inputPanel
                        y: lockScreenRoot.height - lockScreenRoot.height/4
                    }
                }
            ]
            transitions: [
                Transition {
                    from: "hidden"
                    to: "visible"
                    SequentialAnimation {
                        ScriptAction {
                            script: {
                                inputPanel.item.activated = true;
                                Qt.inputMethod.show();
                            }
                        }
                        ParallelAnimation {
                            NumberAnimation {
                                target: mainBlock
                                property: "y"
                                duration: units.longDuration
                                easing.type: Easing.InOutQuad
                            }
                            NumberAnimation {
                                target: inputPanel
                                property: "y"
                                duration: units.longDuration
                                easing.type: Easing.OutQuad
                            }
                        }
                    }
                },
                Transition {
                    from: "visible"
                    to: "hidden"
                    SequentialAnimation {
                        ParallelAnimation {
                            NumberAnimation {
                                target: mainBlock
                                property: "y"
                                duration: units.longDuration
                                easing.type: Easing.InOutQuad
                            }
                            NumberAnimation {
                                target: inputPanel
                                property: "y"
                                duration: units.longDuration
                                easing.type: Easing.InQuad
                            }
                            OpacityAnimator {
                                target: inputPanel
                                duration: units.longDuration
                                easing.type: Easing.InQuad
                            }
                        }
                        ScriptAction {
                            script: {
                                Qt.inputMethod.hide();
                            }
                        }
                    }
                }
            ]
        }

    Component {
        id: passwordArea

        PlasmaComponents.TextField {
            id: passwordBox
            property alias password: passwordBox.text

            // placeholderText: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Password")
            focus: true
            echoMode: TextInput.Password
            enabled: !authenticator.graceLocked

            onAccepted: authenticator.tryUnlock(passwordBox.text)

            Connections {
                target: root
                onClearPassword: {
                    passwordBox.forceActiveFocus()
                    passwordBox.selectAll()
                }
            }

            Text {
                anchors.centerIn: parent
                opacity: 0.6
                visible: passwordBox.text == ""
                color: theme.viewTextColor
                text: i18nd("plasma_lookandfeel_org.kde.lookandfeel",
                            "Password")
            }

            Keys.onPressed: {
                if (event.key == Qt.Key_Escape) {
                    root.clearPassword()
                }

            }
        }
    }


    Component.onCompleted: {
        // version support checks
        if (root.interfaceVersion < 1) {
            // ksmserver of 5.4, with greeter of 5.5
            root.viewVisible = true
        }
    }
}
