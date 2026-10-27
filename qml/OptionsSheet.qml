import QtQuick 2.0
import com.nokia.meego 2.0
import "Util.js" as Util

// "Alarm options", as on the N9: Repeat, Snooze time, Alarm tone, each a
// combo box that opens its list.
Sheet {
    id: options

    property int days: 0
    property int snooze: 10
    property string sound: ""

    acceptButtonText: "Save"
    rejectButtonText: "Cancel"

    content: Flickable {
        anchors.fill: parent
        contentHeight: column.height + 32
        clip: true

        Column {
            id: column

            x: 16
            y: 16
            width: parent.width - 32

            Text {
                height: 64
                verticalAlignment: Text.AlignVCenter
                text: "Alarm options"
                font.family: Util.LIGHT
                font.pixelSize: 32
                color: "#505050"
            }

            OptionRow {
                width: parent.width
                title: "Repeat"
                value: Util.daysText(options.days)
                onClicked: {
                    var sel = []
                    if (options.days === 0)
                        sel.push(0)
                    else if (options.days === Util.ALL_DAYS)
                        sel.push(1)
                    for (var i = 0; i < 7; i++) {
                        if (options.days & Util.dayBits[i])
                            sel.push(i + 2)
                    }
                    repeatDialog.selectedIndexes = sel
                    repeatDialog.open()
                }
            }
            OptionRow {
                width: parent.width
                title: "Snooze time"
                value: options.snooze + (options.snooze === 1 ? " minute" : " minutes")
                onClicked: {
                    snoozeDialog.selectedIndex = Util.snoozeChoices.indexOf(options.snooze)
                    snoozeDialog.open()
                }
            }
            OptionRow {
                width: parent.width
                title: "Alarm tone"
                value: Util.toneName(options.sound)
                onClicked: {
                    var n = Util.toneName(options.sound)
                    toneDialog.selectedIndex = Util.toneNames.indexOf(n)
                    toneDialog.open()
                }
            }
        }
    }

    MultiSelectionDialog {
        id: repeatDialog

        titleText: "Repeat"
        acceptButtonText: "Done"
        model: ListModel {
            ListElement { name: "Never" }
            ListElement { name: "Every day" }
            ListElement { name: "Monday" }
            ListElement { name: "Tuesday" }
            ListElement { name: "Wednesday" }
            ListElement { name: "Thursday" }
            ListElement { name: "Friday" }
            ListElement { name: "Saturday" }
            ListElement { name: "Sunday" }
        }
        onAccepted: {
            var sel = selectedIndexes
            var d = 0
            if (sel.indexOf(1) >= 0) {
                d = Util.ALL_DAYS
            } else {
                for (var i = 0; i < 7; i++) {
                    if (sel.indexOf(i + 2) >= 0)
                        d |= Util.dayBits[i]
                }
            }
            options.days = d
        }
    }

    SelectionDialog {
        id: snoozeDialog

        titleText: "Snooze time"
        model: ListModel {
            Component.onCompleted: {
                for (var i = 0; i < Util.snoozeChoices.length; i++)
                    append({ name: Util.snoozeChoices[i] + " minutes" })
            }
        }
        onAccepted: options.snooze = Util.snoozeChoices[selectedIndex]
    }

    SelectionDialog {
        id: toneDialog

        titleText: "Tones"
        model: ListModel {
            Component.onCompleted: {
                for (var i = 0; i < Util.toneNames.length; i++)
                    append({ name: Util.toneNames[i] })
            }
        }
        onAccepted: options.sound = clockInfo.soundDir + "/" + Util.toneFiles[selectedIndex]
    }
}
