# meego-clock

The Nokia N9's clock for Maemo Leste's Hildon (on Leste and on FreeBSD):
the analog clock with the home city and the alarms, and the alarm editor
with the N9's two-circle time picker, written anew in QML with the MeeGo
Harmattan Qt Quick components (`com.nokia.meego 2.0`, the Qt 5 port of
qt-components) on Maemo's alarm daemon. Nokia's own clock is closed
source; this app imitates its look and behaviour from what the N9 shows,
it contains none of Nokia's code or files.

- **Main view**: the analog clock (dial, hour, minute and orange seconds
  hands), the day and date in the dial, the time zone's city and its
  offset from GMT; the alarms beside it (landscape) or below it
  (portrait), each with its time, name, days and an on/off switch. `+`
  adds an alarm, a tap changes one, a long press deletes it.
- **New or changed alarm**: Cancel and Save, the alarm's name, its time
  large (orange while it is being set), the time picker, "More options".
  The picker: a light ring with a dark knob for the minutes around a dark
  disc with a light knob for the hours; drag a knob round. The hour knob
  goes round twice a day, like an hour hand; in the 12-hour format a
  button beside the time switches between am and pm.
- **Alarm options**: Repeat (never, every day, days of the week), Snooze
  time, Alarm tone.

Alarms are alarmd events made exactly as Maemo's clock (`clock-ui`) makes
them (its application id, texts and actions): both clocks show the same
alarms, and they ring with the system UI's alarm dialog (Snooze, Stop)
and show in the status area clock. The time zone and the 12/24-hour
format come from clockd.

## The look: the N9's theme

The app draws with the meegotouch theme's pictures through
`image://theme/` (the components' theme client): the dial and hands
(`clock-background`, `clock-*-handle`), the time picker
(`meegotouch-timepicker-light-1-*`, `-disc-hours-*`, `-disc-minutes-*`,
`-ambutton`, `-pmbutton`), the components' own, and the clock's orange
(`color16-*`, the colour scheme `darkOrange`); the fonts are Nokia Pure
Text. These are Nokia's: they are not in this repository. Installed from
one's own N9 or N950 firmware (the "blanco" theme in
`/usr/share/themes/blanco` or `/usr/local/share/themes/blanco`, the fonts
in a font directory), the app looks as on the N9. The components need a
patch to find blanco's pictures (in `images/`, not only `icons/`), and
their Harmattan fonts: see the FreeBSD build in
[pro1x-maemo-leste](https://github.com/smatkovi/pro1x-maemo-leste),
`freebsd/hildon/patches/qt-components`.

## Building

Qt 5 (Quick), qt-components' `com.nokia.meego` 2.0 at run time, and
alarmd's `libalarm` and clockd's `libtime` (pkg-config `alarm`,
`libtime`):

    qmake PREFIX=/usr && make && make install

`--fullscreen` starts it without the window's title bar.

## Licence

BSD 3-Clause, see `LICENSE`.
