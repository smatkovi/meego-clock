import QtQuick 2.0
import "Util.js" as Util

// A combo box row as the N9 draws them: the title small and grey, the
// value below it, the combo box arrows at the right.
Item {
    id: row

    property string title
    property string value

    signal clicked

    height: 80

    Rectangle {
        anchors.fill: parent
        color: "#d0d1d2"
        visible: area.pressed
    }

    Column {
        anchors.left: parent.left
        anchors.right: arrow.left
        anchors.verticalCenter: parent.verticalCenter

        Text {
            text: row.title
            font.family: Util.LIGHT
            font.pixelSize: 18
            color: Util.SUBTITLE
        }
        Text {
            width: parent.width
            elide: Text.ElideRight
            text: row.value
            font.family: Util.REGULAR
            font.pixelSize: 24
            color: Util.FOREGROUND
        }
    }

    Image {
        id: arrow
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        source: "image://theme/icon-m-common-combobox-arrow"
    }

    MouseArea {
        id: area
        anchors.fill: parent
        onClicked: row.clicked()
    }
}
