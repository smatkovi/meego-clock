// What the clock shows besides the time: clockd's time zone (the city and
// its offset from GMT) and its 12- or 24-hour format.
#ifndef CLOCKINFO_H
#define CLOCKINFO_H

#include <QObject>
#include <QString>

class ClockInfo : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString city READ city NOTIFY changed)
    Q_PROPERTY(QString offset READ offset NOTIFY changed)
    Q_PROPERTY(bool use24h READ use24h NOTIFY changed)
    // where Leste's alarm tones are (ui-clock_alarm_*.aac)
    Q_PROPERTY(QString soundDir READ soundDir CONSTANT)
    // mce's display_status_ind: false while the display is off or shows
    // the stand-by screen ("off", "lpm"); the seconds hand stops then
    Q_PROPERTY(bool displayOn READ displayOn NOTIFY displayChanged)

public:
    explicit ClockInfo(QObject *parent = nullptr);

    QString city() const { return m_city; }
    QString offset() const { return m_offset; }
    bool use24h() const { return m_use24h; }
    QString soundDir() const;
    bool displayOn() const { return m_displayOn; }

    Q_INVOKABLE void refresh();

signals:
    void changed();
    void displayChanged();

private slots:
    void displayStatus(const QString &state);

private:
    bool m_displayOn = true;
    QString m_city;
    QString m_offset;
    bool m_use24h = true;
};

#endif
