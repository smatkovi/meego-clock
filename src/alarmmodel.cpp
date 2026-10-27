#include "alarmmodel.h"

#include <libalarm.h>

#include <algorithm>
#include <cstdlib>
#include <ctime>

// Alarms are made as Maemo's clock (clock-ui) makes them, with its
// application id and texts: both clocks show the same alarms, and the
// system UI's alarm dialog shows them with the clock's Snooze and Stop.
static const char APPID[] = "worldclock_alarmd_id";
static const char TEXTDOMAIN[] = "osso-clock";

static Alarm fromEvent(const alarm_event_t *e)
{
    Alarm a;
    const char *s;

    a.cookie = int(alarm_event_get_cookie(e));
    s = alarm_event_get_message(e);
    a.title = QString::fromUtf8(s ? s : "");
    a.enabled = !(e->flags & ALARM_EVENT_DISABLED);
    if (e->recurrence_cnt > 0) {
        const alarm_recur_t *r = alarm_event_get_recurrence(e, 0);
        a.days = int(r->mask_wday & ALARM_RECUR_WDAY_ALL);
        for (int h = 0; h < 24; h++) {
            if (r->mask_hour & (1u << h)) {
                a.hour = h;
                break;
            }
        }
        for (int m = 0; m < 60; m++) {
            if (r->mask_min & (1ull << m)) {
                a.minute = m;
                break;
            }
        }
    } else if (e->alarm_tm.tm_hour >= 0) {
        a.hour = e->alarm_tm.tm_hour;
        a.minute = e->alarm_tm.tm_min < 0 ? 0 : e->alarm_tm.tm_min;
    } else if (e->alarm_time > 0) {
        struct tm tm;
        time_t t = e->alarm_time;
        localtime_r(&t, &tm);
        a.hour = tm.tm_hour;
        a.minute = tm.tm_min;
    }
    a.snooze = int(e->snooze_secs / 60);
    s = alarm_event_get_sound(e);
    a.sound = QString::fromUtf8(s ? s : "");
    a.trigger = a.enabled ? qint64(alarm_event_get_trigger(e)) : 0;
    return a;
}

AlarmModel::AlarmModel(QObject *parent)
    : QAbstractListModel(parent)
{
    refresh();
}

int AlarmModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : m_alarms.size();
}

QVariant AlarmModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_alarms.size())
        return QVariant();
    const Alarm &a = m_alarms.at(index.row());
    switch (role) {
    case CookieRole: return a.cookie;
    case HourRole: return a.hour;
    case MinuteRole: return a.minute;
    case TitleRole: return a.title;
    case EnabledRole: return a.enabled;
    case DaysRole: return a.days;
    case SnoozeRole: return a.snooze;
    case SoundRole: return a.sound;
    case TriggerRole: return a.trigger;
    }
    return QVariant();
}

QHash<int, QByteArray> AlarmModel::roleNames() const
{
    return {
        { CookieRole, "cookie" },
        { HourRole, "hour" },
        { MinuteRole, "minute" },
        { TitleRole, "title" },
        { EnabledRole, "enabled" },
        { DaysRole, "days" },
        { SnoozeRole, "snooze" },
        { SoundRole, "sound" },
        { TriggerRole, "trigger" },
    };
}

void AlarmModel::refresh()
{
    QVector<Alarm> list;
    cookie_t *cookies = alarmd_event_query(0, 0, 0, 0, APPID);

    for (cookie_t *c = cookies; c && *c; c++) {
        alarm_event_t *e = alarmd_event_get(*c);
        if (e) {
            list.append(fromEvent(e));
            alarm_event_delete(e);
        }
    }
    free(cookies);
    std::sort(list.begin(), list.end(), [](const Alarm &a, const Alarm &b) {
        return a.hour * 60 + a.minute < b.hour * 60 + b.minute;
    });
    beginResetModel();
    m_alarms = list;
    endResetModel();
    emit countChanged();
}

int AlarmModel::save(int cookie, int hour, int minute, const QString &title,
                     int days, int snooze, const QString &sound, bool enabled)
{
    alarm_event_t *e = alarm_event_create();
    alarm_action_t *act;
    cookie_t c;

    alarm_event_set_alarm_appid(e, APPID);
    alarm_event_set_message(e, title.toUtf8().constData());
    alarm_event_set_attr_string(e, "textdomain", TEXTDOMAIN);

    act = alarm_event_add_actions(e, 1);
    alarm_action_set_label(act, "cloc_bd_alarm_notification_snooze");
    act->flags = ALARM_ACTION_WHEN_RESPONDED | ALARM_ACTION_TYPE_SNOOZE;

    e->flags |= ALARM_EVENT_ACTDEAD | ALARM_EVENT_SHOW_ICON | ALARM_EVENT_POSTPONE_DELAYED;
    if (!enabled)
        e->flags |= ALARM_EVENT_DISABLED;

    act = alarm_event_add_actions(e, 1);
    alarm_action_set_label(act, "cloc_bd_stop");
    days &= ALARM_RECUR_WDAY_ALL;
    if (days) {
        // on these days, every week; Stop leaves it for the next one
        e->flags |= ALARM_EVENT_BACK_RESCHEDULE;
        act->flags = ALARM_ACTION_WHEN_RESPONDED | ALARM_ACTION_TYPE_NOP;
        e->recur_count = -1;
        e->recur_secs = 0;
        alarm_recur_t *r = alarm_event_add_recurrences(e, 1);
        r->special = ALARM_RECUR_SPECIAL_NONE;
        r->mask_mon = ALARM_RECUR_MON_ALL;
        r->mask_mday = ALARM_RECUR_MDAY_ALL;
        r->mask_hour = 1u << hour;
        r->mask_min = 1ull << minute;
        r->mask_wday = unsigned(days);
    } else {
        // once, at the next such time; Stop disables it
        act->flags = ALARM_ACTION_WHEN_RESPONDED | ALARM_ACTION_TYPE_DISABLE;
        e->alarm_time = -1;
        e->alarm_tm.tm_hour = hour;
        e->alarm_tm.tm_min = minute;
    }
    if (snooze > 0)
        e->snooze_secs = time_t(snooze) * 60;
    if (!sound.isEmpty())
        alarm_event_set_sound(e, sound.toUtf8().constData());

    if (cookie > 0) {
        alarm_event_set_cookie(e, cookie_t(cookie));
        c = alarmd_event_update(e);
    } else {
        c = alarmd_event_add(e);
    }
    alarm_event_delete(e);
    refresh();
    return int(c);
}

bool AlarmModel::setEnabled(int cookie, bool enabled)
{
    const Alarm *a = find(cookie);
    if (!a)
        return false;
    if (a->enabled == enabled)
        return true;
    // made anew, so that a single alarm gets its next time again
    Alarm copy = *a;
    return save(cookie, copy.hour, copy.minute, copy.title, copy.days,
                copy.snooze, copy.sound, enabled) > 0;
}

bool AlarmModel::remove(int cookie)
{
    bool ok = alarmd_event_del(cookie_t(cookie)) == 0;
    refresh();
    return ok;
}

QVariantMap AlarmModel::get(int cookie) const
{
    QVariantMap m;
    const Alarm *a = find(cookie);
    if (a) {
        m["cookie"] = a->cookie;
        m["hour"] = a->hour;
        m["minute"] = a->minute;
        m["title"] = a->title;
        m["enabled"] = a->enabled;
        m["days"] = a->days;
        m["snooze"] = a->snooze;
        m["sound"] = a->sound;
        m["trigger"] = a->trigger;
    }
    return m;
}

const Alarm *AlarmModel::find(int cookie) const
{
    for (const Alarm &a : m_alarms) {
        if (a.cookie == cookie)
            return &a;
    }
    return nullptr;
}
