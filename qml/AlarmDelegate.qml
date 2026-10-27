import QtQuick 2.0
import com.nokia.meego 2.0
import "Util.js" as Util

// One alarm: its time large, its name and days below, the switch at the
// right (the clock's orange when on).
Item {
    id: row

    signal clicked
    signal pressAndHold

    height: 100

    Rectangle {
        anchors.fill: parent
        color: "#d0d1d2"
        visible: area.pressed
    }

    MouseArea {
        id: area
        anchors.fill: parent
        onClicked: row.clicked()
        onPressAndHold: row.pressAndHold()
    }

    Column {
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.right: toggle.left
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter

        Row {
            spacing: 6

            Text {
                text: Util.timeText(model.hour, model.minute, clockInfo.use24h)
                font.family: Util.LIGHT_T
                font.pixelSize: 48
                color: model.enabled ? Util.FOREGROUND : Util.SUBTITLE
            }
            Text {
                visible: !clockInfo.use24h
                anchors.baseline: parent.children[0].baseline
                text: Util.ampm(model.hour)
                font.family: Util.LIGHT
                font.pixelSize: 24
                color: model.enabled ? Util.FOREGROUND : Util.SUBTITLE
            }
        }
        Text {
            width: parent.width
            elide: Text.ElideRight
            text: model.title !== "" ? model.title + "  " + Util.daysText(model.days) : Util.daysText(model.days)
            font.family: Util.LIGHT
            font.pixelSize: 22
            color: Util.SUBTITLE
        }
    }

    Switch {
        id: toggle

        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        checked: model.enabled
        onCheckedChanged: {
            if (checked !== model.enabled)
                alarms.setEnabled(model.cookie, checked)
        }
    }

    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        height: 1
        color: "#c7c7c7"
    }
}
