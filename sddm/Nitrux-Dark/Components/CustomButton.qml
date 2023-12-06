import QtQuick 2.1
import QtQuick.Controls 1.2 as QtControls
import QtQuick.Controls.Styles.Plasma 2.0 as Styles

QtControls.Button {
    id: root
    property font font: theme.defaultFont

    /*
    * overrides iconsource for compatibility
    */

    property alias iconSource: root.iconName

    property real minimumWidth: 0

    property real minimumHeight: 0

    style: Styles.ButtonStyle {}
}
