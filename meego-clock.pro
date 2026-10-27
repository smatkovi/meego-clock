TEMPLATE = app
TARGET = meego-clock

QT += quick qml
CONFIG += c++11 link_pkgconfig
PKGCONFIG += alarm libtime

SOURCES += src/main.cpp src/alarmmodel.cpp src/clockinfo.cpp
HEADERS += src/alarmmodel.h src/clockinfo.h
RESOURCES += meego-clock.qrc

isEmpty(PREFIX): PREFIX = /usr

target.path = $$PREFIX/bin
desktop.files = data/meego-clock.desktop
desktop.path = $$PREFIX/share/applications/hildon
INSTALLS += target desktop
