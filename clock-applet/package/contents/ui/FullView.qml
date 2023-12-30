import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2
ColumnLayout {
    Layout.minimumHeight: Screen.desktopAvailableWidth
    CalendarView {
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignTop
    }

    WeatherView {
        visible: plasmoid.configuration.show_weather

        Layout.minimumHeight: 60
        Layout.rightMargin: 18
        Layout.leftMargin: 12
        Layout.fillWidth: true
    }
}
