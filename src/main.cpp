// meego-clock: the Nokia N9's clock (alarms and their two-circle time
// picker) for Maemo Leste's Hildon, in QML with the MeeGo Harmattan
// components (com.nokia.meego 2.0) and alarmd.
#include <QGuiApplication>
#include <QQmlContext>
#include <QQmlEngine>
#include <QQuickView>

#include "alarmmodel.h"
#include "clockinfo.h"

int main(int argc, char **argv)
{
    QGuiApplication app(argc, argv);
    app.setApplicationName(QStringLiteral("meego-clock"));

    // one of each for all of the QML files
    AlarmModel alarms;
    ClockInfo clockInfo;

    QQuickView view;
    view.rootContext()->setContextProperty(QStringLiteral("alarms"), &alarms);
    view.rootContext()->setContextProperty(QStringLiteral("clockInfo"), &clockInfo);
    view.setTitle(QStringLiteral("Clock"));
    view.setResizeMode(QQuickView::SizeRootObjectToView);
    view.setSource(QUrl(QStringLiteral("qrc:/qml/main.qml")));
    if (app.arguments().contains(QStringLiteral("--fullscreen")))
        view.showFullScreen();
    else
        view.show();
    return app.exec();
}
