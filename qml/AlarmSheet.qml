import QtQuick 2.0
import com.nokia.meego 2.0
import "Util.js" as Util

// New or changed alarm, as on the N9: Cancel and Save at the top, the
// alarm's name, its time large (the clock's orange while a knob is
// dragged), the two-circle time picker and "More options".
Sheet {
    id: sheet

    property int cookie: 0
    property int days: 0
    property int snooze: 10
    property string sound: ""

    signal saved(int cookie)
    // "More options": the page opens the options sheet beside this one
    signal moreOptions

    acceptButtonText: "Save"
    rejectButtonText: "Cancel"

    function openNew() {
        cookie = 0
        picker.hours = 8
        picker.minutes = 0
        titleField.text = ""
        days = 0
        snooze = 10
        sound = clockInfo.soundDir + "/" + Util.toneFiles[0]
        open()
    }

    function openAlarm(a) {
        if (a.cookie === undefined)
            return
        cookie = a.cookie
        picker.hours = a.hour
        picker.minutes = a.minute
        titleField.text = a.title
        days = a.days
        snooze = a.snooze > 0 ? a.snooze : 10
        sound = a.sound !== "" ? a.sound : clockInfo.soundDir + "/" + Util.toneFiles[0]
        open()
    }

    onAccepted: {
        var c = alarms.save(cookie, picker.hours, picker.minutes, titleField.text,
                            days, snooze, sound, true)
        if (c > 0)
            sheet.saved(c)
    }

    content: Item {
        id: body

        readonly property bool landscape: width > height

        anchors.fill: parent

        TimePicker {
            id: picker

            use24h: clockInfo.use24h
            width: body.landscape ? Math.min(356, body.height - 24)
                                  : Math.min(400, body.width - 32,
                                             body.height - (body.landscape ? 0 : 320))
            x: body.landscape ? 24 : (body.width - width) / 2
            y: body.landscape ? (body.height - height) / 2 : fields.y + fields.height + 8
        }

        Column {
            id: fields

            x: body.landscape ? picker.x + picker.width + 32 : 16
            y: 16
            width: body.width - x - 16
            spacing: 8

            TextField {
                id: titleField
                width: parent.width
                placeholderText: "Alarm title"
            }

            Item {
                id: timeRow

                width: parent.width
                height: 90

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 12

                    Text {
                        id: timeLabel
                        text: Util.timeText(picker.hours, picker.minutes, clockInfo.use24h)
                        font.family: Util.LIGHT_T
                        font.pixelSize: 60
                        color: picker.pressed ? Util.ACCENT : Util.FOREGROUND
                    }

                    // 12 hours: am (black) or pm (blue), the theme's buttons
                    Item {
                        visible: !clockInfo.use24h
                        anchors.verticalCenter: timeLabel.verticalCenter
                        width: 42
                        height: 42

                        Image {
                            anchors.fill: parent
                            source: "image://theme/meegotouch-timepicker-"
                                    + (picker.hours < 12 ? "am" : "pm") + "button"
                        }
                        Text {
                            anchors.centerIn: parent
                            text: Util.ampm(picker.hours)
                            font.family: Util.REGULAR
                            font.pixelSize: 18
                            color: "#ffffff"
                        }
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -12
                            onClicked: picker.hours = (picker.hours + 12) % 24
                        }
                    }
                }
            }
        }

        // "More options >"
        Item {
            id: moreOptions

            x: fields.x
            width: fields.width
            height: 80
            y: body.landscape ? body.height - height - 8 : body.height - height

            Rectangle {
                anchors.fill: parent
                color: "#d0d1d2"
                visible: moreArea.pressed
            }
            Text {
                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                text: "More options"
                font.family: Util.REGULAR
                font.pixelSize: 24
                color: Util.FOREGROUND
            }
            Image {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                source: "image://theme/icon-m-common-drilldown-arrow"
            }
            MouseArea {
                id: moreArea
                anchors.fill: parent
                onClicked: sheet.moreOptions()
            }
        }
    }
}
