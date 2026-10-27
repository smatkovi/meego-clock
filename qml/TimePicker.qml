import QtQuick 2.0
import "Util.js" as Util

// The N9 clock's time picker: a light ring with a dark knob for the
// minutes around a dark disc with a light knob for the hours; drag a
// knob round. The pictures are the theme's (meegotouch-timepicker-*:
// light-1 the dial, disc-minutes and disc-hours a knob at twelve o'clock
// on the whole dial's canvas, turned about the centre); the numbers on
// the knobs are drawn upright, light, white on the minutes, black on the
// hours (libtimepicker.css). Portrait pictures are 400 wide, landscape
// ones 356; the knobs' places measured from them.
//
// The hour knob goes round twice a day, as an hour hand: past twelve
// o'clock it turns from am to pm and back.
Item {
    id: picker

    property int hours: 8
    property int minutes: 0
    property bool use24h: true
    readonly property bool pressed: area.ring !== 0

    readonly property bool small: width < 378
    readonly property string variant: small ? "landscape" : "portrait"
    readonly property real s: width / (small ? 356 : 400)
    readonly property real minuteRadius: (small ? 137.5 : 152.5) * s
    readonly property real hourRadius: (small ? 59 : 65) * s
    readonly property real discRadius: (small ? 97.5 : 109.5) * s
    readonly property real knobFont: (small ? 28 : 32) * s

    width: 400
    height: width

    function knobX(angle, radius, item) {
        return width / 2 + radius * Math.sin(angle * Math.PI / 180) - item.width / 2
    }
    function knobY(angle, radius, item) {
        return height / 2 - radius * Math.cos(angle * Math.PI / 180) - item.height / 2
    }

    Image {
        anchors.fill: parent
        source: "image://theme/meegotouch-timepicker-light-1-" + picker.variant
        smooth: true
    }
    Image {
        anchors.fill: parent
        source: "image://theme/meegotouch-timepicker-disc-hours-" + picker.variant
        smooth: true
        rotation: (picker.hours % 12) * 30
    }
    Image {
        anchors.fill: parent
        source: "image://theme/meegotouch-timepicker-disc-minutes-" + picker.variant
        smooth: true
        rotation: picker.minutes * 6
    }

    Text {
        id: hourText
        x: picker.knobX((picker.hours % 12) * 30, picker.hourRadius, hourText)
        y: picker.knobY((picker.hours % 12) * 30, picker.hourRadius, hourText)
        text: picker.use24h ? Util.pad(picker.hours)
                            : Util.pad(picker.hours % 12 === 0 ? 12 : picker.hours % 12)
        font.family: Util.LIGHT
        font.pixelSize: picker.knobFont
        color: "#000000"
    }
    Text {
        id: minuteText
        x: picker.knobX(picker.minutes * 6, picker.minuteRadius, minuteText)
        y: picker.knobY(picker.minutes * 6, picker.minuteRadius, minuteText)
        text: Util.pad(picker.minutes)
        font.family: Util.LIGHT
        font.pixelSize: picker.knobFont
        color: "#ffffff"
    }

    MouseArea {
        id: area

        // 1: the hours (on the dark disc), 2: the minutes (on the ring)
        property int ring: 0
        property int lastPosition: 0

        anchors.fill: parent
        preventStealing: true

        function angleAt(mouse) {
            var a = Math.atan2(mouse.x - width / 2, height / 2 - mouse.y) * 180 / Math.PI
            return a < 0 ? a + 360 : a
        }

        function follow(mouse) {
            var a = angleAt(mouse)
            if (ring === 2) {
                picker.minutes = Math.round(a / 6) % 60
            } else if (ring === 1) {
                var p = Math.round(a / 30) % 12
                var pm = picker.hours >= 12
                // across twelve o'clock, either way: the other half of the day
                if ((lastPosition >= 9 && p <= 2) || (lastPosition <= 2 && p >= 9))
                    pm = !pm
                lastPosition = p
                picker.hours = p + (pm ? 12 : 0)
            }
        }

        onPressed: {
            var dx = mouse.x - width / 2, dy = mouse.y - height / 2
            var d = Math.sqrt(dx * dx + dy * dy)
            if (d <= picker.discRadius)
                ring = 1
            else if (d <= width / 2)
                ring = 2
            else {
                ring = 0
                mouse.accepted = false
                return
            }
            lastPosition = picker.hours % 12
            follow(mouse)
        }
        onPositionChanged: follow(mouse)
        onReleased: ring = 0
        onCanceled: ring = 0
    }
}
