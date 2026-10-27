.pragma library

// The N9 clock's colours and fonts (blanco's constants and clock.css)
var ACCENT = "#F77219"            // COLOR_ACCENT16, the clock's colour
var FOREGROUND = "#282828"
var SUBTITLE = "#8c8c8c"
var LIGHT = "Nokia Pure Text Light"
var LIGHT_T = "Nokia Pure Text T Light"   // tabular digits
var REGULAR = "Nokia Pure Text"

function pad(n) {
    return n < 10 ? "0" + n : "" + n
}

// "08:00" in 24 hours, "8:00" in 12 (am/pm apart)
function timeText(hour, minute, use24h) {
    if (use24h)
        return pad(hour) + ":" + pad(minute)
    var h = hour % 12
    return (h === 0 ? 12 : h) + ":" + pad(minute)
}

function ampm(hour) {
    return hour < 12 ? "am" : "pm"
}

// alarmd's ALARM_RECUR_WDAY_* bits, Monday first: Sunday is 1 << 0
var dayBits = [2, 4, 8, 16, 32, 64, 1]
var dayNames = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
var dayShort = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
var ALL_DAYS = 127

function daysText(days) {
    if (days === 0)
        return "Never"
    if (days === ALL_DAYS)
        return "Every day"
    var out = []
    for (var i = 0; i < 7; i++) {
        if (days & dayBits[i])
            out.push(dayShort[i])
    }
    return out.join(", ")
}

// "Alarm in 7 hours 30 minutes", as the N9 says it after saving
function untilText(trigger) {
    var s = trigger - Math.floor(Date.now() / 1000)
    if (s < 60)
        return "Alarm in less than a minute"
    var m = Math.round(s / 60)
    var d = Math.floor(m / 1440)
    var h = Math.floor((m % 1440) / 60)
    m = m % 60
    var parts = []
    if (d > 0)
        parts.push(d + (d === 1 ? " day" : " days"))
    if (h > 0)
        parts.push(h + (h === 1 ? " hour" : " hours"))
    if (m > 0 && d === 0)
        parts.push(m + (m === 1 ? " minute" : " minutes"))
    return "Alarm in " + parts.join(" ")
}

var snoozeChoices = [2, 5, 10, 15, 20, 30]

// Leste's alarm tones
var toneNames = ["Clock 1", "Clock 2", "Clock 3"]
var toneFiles = ["ui-clock_alarm_default.aac", "ui-clock_alarm_2.aac", "ui-clock_alarm_3.aac"]

function toneName(path) {
    for (var i = 0; i < toneFiles.length; i++) {
        if (path.indexOf(toneFiles[i], path.length - toneFiles[i].length) !== -1)
            return toneNames[i]
    }
    if (path === "")
        return toneNames[0]
    return path.substring(path.lastIndexOf("/") + 1)
}
