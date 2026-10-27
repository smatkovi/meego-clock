import QtQuick 2.0
import com.nokia.meego 2.0
import "Util.js" as Util

// The clock's main view: the analog clock with the home city on its
// panel (#f0f1f2, 432 wide in landscape, 509 high in portrait) and the
// alarms beside or below it (#e6e7e8).
Page {
    id: page

    readonly property bool landscape: width > height

    orientationLock: PageOrientation.Automatic

    Rectangle {
        anchors.fill: parent
        color: "#e6e7e8"
    }

    Rectangle {
        id: clockPanel

        color: "#f0f1f2"
        width: page.landscape ? 432 : page.width
        height: page.landscape ? page.height : Math.min(509, page.height * 0.55)

        Text {
            id: location
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 22
            text: clockInfo.city ? clockInfo.city + " " + clockInfo.offset : clockInfo.offset
            font.family: Util.LIGHT
            font.pixelSize: 18
            color: "#505050"
        }

        AnalogClock {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: location.bottom
            anchors.topMargin: 12
            width: Math.min(384, clockPanel.height - location.height - 46,
                            clockPanel.width - 32)
        }
    }

    // the theme's drop shadow along the panel's edge
    Image {
        visible: !page.landscape
        anchors.top: clockPanel.bottom
        width: page.width
        height: 8
        source: "image://theme/meegotouch-clock-dropshadow"
    }

    Item {
        id: alarmsPart

        x: page.landscape ? clockPanel.width : 0
        y: page.landscape ? 0 : clockPanel.height
        width: page.width - x
        height: page.height - y

        Item {
            id: header

            width: parent.width
            height: 72

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                text: "Alarms"
                font.family: Util.LIGHT
                font.pixelSize: 32
                color: Util.FOREGROUND
            }

            // CommonSmallIconButton: a plus, the accent behind it when pressed
            Item {
                id: addButton

                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                width: 64
                height: 56

                BorderImage {
                    anchors.fill: parent
                    visible: addArea.pressed
                    source: "image://theme/color16-meegotouch-button-background-pressed"
                    border { left: 10; right: 10; top: 10; bottom: 10 }
                }
                Image {
                    anchors.centerIn: parent
                    source: "image://theme/icon-m-common-add"
                }
                MouseArea {
                    id: addArea
                    anchors.fill: parent
                    onClicked: alarmSheet.openNew()
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

        ListView {
            id: list

            anchors.top: header.bottom
            anchors.bottom: parent.bottom
            width: parent.width
            clip: true
            model: alarms
            delegate: AlarmDelegate {
                width: list.width
                onClicked: alarmSheet.openAlarm(alarms.get(model.cookie))
                onPressAndHold: {
                    contextMenu.cookie = model.cookie
                    contextMenu.open()
                }
            }
        }

        ScrollDecorator {
            flickableItem: list
        }

        Text {
            anchors.centerIn: list
            visible: alarms.count === 0
            text: "No alarms"
            font.family: Util.LIGHT
            font.pixelSize: 32
            color: "#b2b2b4"
        }
    }

    ContextMenu {
        id: contextMenu

        property int cookie: 0

        MenuLayout {
            MenuItem {
                text: "Delete"
                onClicked: alarms.remove(contextMenu.cookie)
            }
        }
    }

    AlarmSheet {
        id: alarmSheet
        onMoreOptions: {
            optionsSheet.days = days
            optionsSheet.snooze = snooze
            optionsSheet.sound = sound
            optionsSheet.open()
        }
        // "Alarm in ...", once the sheet is out of the way
        property string pendingBanner: ""
        onSaved: {
            var a = alarms.get(cookie)
            if (a.trigger > 0)
                pendingBanner = Util.untilText(a.trigger)
        }
        onStatusChanged: {
            if (status === DialogStatus.Closed && pendingBanner !== "") {
                banner.text = pendingBanner
                pendingBanner = ""
                banner.show()
            }
        }
    }

    // declared after the alarm sheet: opened over it
    OptionsSheet {
        id: optionsSheet
        onAccepted: {
            alarmSheet.days = days
            alarmSheet.snooze = snooze
            alarmSheet.sound = sound
        }
    }

    InfoBanner {
        id: banner
        topMargin: 8
    }
}
