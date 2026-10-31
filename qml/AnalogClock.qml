import QtQuick 2.0
import "Util.js" as Util

// The N9's analog clock (AnalogClockStyle in its clock.css): the dial
// and the hands are the theme's 384x384 pictures, the hands drawn at
// twelve o'clock and turned about the centre; day and date at the left.
Item {
    id: clock

    property date now: new Date()
    readonly property real s: width / 384

    width: 384
    height: width

    // the seconds hand only while it is seen: the clock in front and the
    // display on (no wakeup a second behind other windows or in a pocket)
    Timer {
        interval: 1000
        running: Qt.application.active && clockInfo.displayOn
        repeat: true
        triggeredOnStart: true
        onTriggered: clock.now = new Date()
    }

    Image {
        anchors.fill: parent
        source: "image://theme/clock-background"
        smooth: true
    }

    // date-info-area: 16 from the left, 172 from the top, 62x62
    Column {
        x: 16 * clock.s
        y: 172 * clock.s - dayLabel.height
        spacing: -4 * clock.s

        Text {
            id: dayLabel
            text: Qt.formatDate(clock.now, "ddd").toUpperCase()
            font.family: Util.LIGHT
            font.pixelSize: 18 * clock.s
            color: "#505050"
        }
        Text {
            text: Util.pad(clock.now.getDate())
            font.family: Util.LIGHT
            font.pixelSize: 48 * clock.s
            color: "#191919"
        }
    }

    Image {
        anchors.fill: parent
        source: "image://theme/clock-hour-handle"
        smooth: true
        rotation: (clock.now.getHours() % 12) * 30 + clock.now.getMinutes() / 2
    }
    Image {
        anchors.fill: parent
        source: "image://theme/clock-minute-handle"
        smooth: true
        rotation: clock.now.getMinutes() * 6 + clock.now.getSeconds() / 10
    }
    Image {
        anchors.fill: parent
        source: "image://theme/clock-seconds-handle"
        smooth: true
        rotation: clock.now.getSeconds() * 6
    }
}
