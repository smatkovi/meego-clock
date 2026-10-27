// The clock's alarms in alarmd's queue, as a list model for QML.
#ifndef ALARMMODEL_H
#define ALARMMODEL_H

#include <QAbstractListModel>
#include <QVariantMap>
#include <QVector>

struct Alarm {
    int cookie = 0;
    int hour = 0;
    int minute = 0;
    QString title;
    bool enabled = true;
    int days = 0;          // alarmd's ALARM_RECUR_WDAY_* bits; 0: once
    int snooze = 0;        // minutes; 0: alarmd's default
    QString sound;
    qint64 trigger = 0;    // when it rings next (time_t); 0 when disabled
};

class AlarmModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    enum Roles {
        CookieRole = Qt::UserRole + 1,
        HourRole,
        MinuteRole,
        TitleRole,
        EnabledRole,
        DaysRole,
        SnoozeRole,
        SoundRole,
        TriggerRole
    };

    explicit AlarmModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;
    int count() const { return m_alarms.size(); }

    // all from alarmd again
    Q_INVOKABLE void refresh();
    // a new alarm (cookie 0) or the alarm with this cookie changed; the
    // alarm's cookie, 0 when alarmd refused it
    Q_INVOKABLE int save(int cookie, int hour, int minute, const QString &title,
                         int days, int snooze, const QString &sound, bool enabled);
    Q_INVOKABLE bool setEnabled(int cookie, bool enabled);
    Q_INVOKABLE bool remove(int cookie);
    // the alarm as a map with the role names as keys (empty if unknown)
    Q_INVOKABLE QVariantMap get(int cookie) const;

signals:
    void countChanged();

private:
    const Alarm *find(int cookie) const;

    QVector<Alarm> m_alarms;
};

#endif
