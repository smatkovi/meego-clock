#include "clockinfo.h"

#include <clockd/libtime.h>

#include <QDBusConnection>
#include <QFile>

#include <cstdlib>
#include <cstring>
#include <ctime>

ClockInfo::ClockInfo(QObject *parent)
    : QObject(parent)
{
    refresh();
    // (from any sender: where no mce runs, pro1x-standby says it)
    QDBusConnection::systemBus().connect(QString(), QStringLiteral("/com/nokia/mce/signal"),
                                         QStringLiteral("com.nokia.mce.signal"),
                                         QStringLiteral("display_status_ind"), this,
                                         SLOT(displayStatus(QString)));
}

void ClockInfo::displayStatus(const QString &state)
{
    const bool on = state != QLatin1String("off") && state != QLatin1String("lpm");

    if (on != m_displayOn) {
        m_displayOn = on;
        emit displayChanged();
    }
}

QString ClockInfo::soundDir() const
{
    // FreeBSD keeps them below /usr/local, Leste below /usr
    if (QFile::exists(QStringLiteral("/usr/local/share/sounds/ui-clock_alarm_default.aac")))
        return QStringLiteral("/usr/local/share/sounds");
    return QStringLiteral("/usr/share/sounds");
}

void ClockInfo::refresh()
{
    char buf[256];
    QString city, offset;
    bool use24h = true;

    // ":Europe/Vienna" -> "Vienna"
    if (time_get_timezone(buf, sizeof buf) > 0) {
        QString tz = QString::fromUtf8(buf);
        if (tz.startsWith(':'))
            tz.remove(0, 1);
        city = tz.section('/', -1).replace('_', ' ');
    }

    // as the N9 writes it: GMT+1:00, GMT-3:30, GMT
    struct tm tm;
    time_t now = time(nullptr);
    localtime_r(&now, &tm);
    long off = tm.tm_gmtoff;
    if (off == 0) {
        offset = QStringLiteral("GMT");
    } else {
        long a = labs(off);
        offset = QString::asprintf("GMT%c%ld:%02ld", off < 0 ? '-' : '+',
                                   a / 3600, (a % 3600) / 60);
    }

    // clockd's format, as the status area clock reads it: "%R" is 24 hours
    if (time_get_time_format(buf, sizeof buf) >= 0)
        use24h = strcmp(buf, "%R") == 0;

    if (city != m_city || offset != m_offset || use24h != m_use24h) {
        m_city = city;
        m_offset = offset;
        m_use24h = use24h;
        emit changed();
    }
}
