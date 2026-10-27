import QtQuick 2.0
import com.nokia.meego 2.0

PageStackWindow {
    id: window

    // Hildon has its own status bar; no tool bar, as the N9's clock
    showStatusBar: false
    showToolBar: false
    initialPage: MainPage {}

    Component.onCompleted: {
        // the clock's orange (blanco's color16)
        theme.colorScheme = "darkOrange"
        theme.inverted = false
    }

    // alarms change elsewhere too (clock-ui, the alarm dialog)
    Timer {
        interval: 30000
        running: Qt.application.active
        repeat: true
        onTriggered: {
            alarms.refresh()
            clockInfo.refresh()
        }
    }
    Connections {
        target: Qt.application
        onActiveChanged: {
            if (Qt.application.active) {
                alarms.refresh()
                clockInfo.refresh()
            }
        }
    }
}
