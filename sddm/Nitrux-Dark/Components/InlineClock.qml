import QtQuick 2.0

Text {
    id: clock

    property date dateTime: new Date()

    Timer {
        interval: 1000; running: true; repeat: true;
        onTriggered: clock.dateTime = new Date()
    }

    color: "white"

    height: parent.height
    anchors.verticalCenter: parent.verticalCenter
    verticalAlignment: Text.AlignVCenter

    text: Qt.formatTime(clock.dateTime, "hh:mm")

    font.family: "Noto Sans"
    font.pointSize: 10
    font.weight: Font.Bold
}
