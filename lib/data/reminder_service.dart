import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'prefs.dart';

/// Texts of the reminder, in the app's language. They never contain amounts –
/// the notification is visible on the lock screen.
class ReminderTexts {
  const ReminderTexts({required this.channel, required this.title, required this.body});

  final String channel;
  final String title;
  final String body;
}

/// Local reminder to enter the balances. This base class does nothing (tests,
/// or when the notification plugin is unavailable); see [LocalReminderService].
class ReminderService {
  ReminderService();

  /// Set when a reminder was tapped – the app then opens the balance entry
  /// once it is unlocked.
  final captureRequested = ValueNotifier(false);

  Future<bool> requestPermission() async => false;

  Future<void> schedule(ReminderPrefs prefs, ReminderTexts texts) async {}

  Future<void> cancelAll() async {}
}

class LocalReminderService extends ReminderService {
  LocalReminderService._(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  static const _payload = 'capture';
  static const _channelId = 'reminders';

  /// Initialises the plugin and the time zone; null when that fails.
  static Future<LocalReminderService?> create() async {
    try {
      tzdata.initializeTimeZones();
      try {
        final zone = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(zone.identifier));
      } catch (_) {
        tz.setLocalLocation(tz.getLocation('Europe/Vienna'));
      }
      final plugin = FlutterLocalNotificationsPlugin();
      final service = LocalReminderService._(plugin);
      await plugin.initialize(
        settings: const InitializationSettings(android: AndroidInitializationSettings('ic_notification')),
        onDidReceiveNotificationResponse: (r) {
          if (r.payload == _payload) service.captureRequested.value = true;
        },
      );
      final launch = await plugin.getNotificationAppLaunchDetails();
      if (launch?.didNotificationLaunchApp == true && launch?.notificationResponse?.payload == _payload) {
        service.captureRequested.value = true;
      }
      return service;
    } catch (e) {
      debugPrint('notifications unavailable: $e');
      return null;
    }
  }

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  @override
  Future<bool> requestPermission() async {
    final android = _android;
    if (android == null) return false;
    if (await android.areNotificationsEnabled() == true) return true;
    return await android.requestNotificationsPermission() ?? false;
  }

  @override
  Future<void> schedule(ReminderPrefs prefs, ReminderTexts texts) async {
    await _plugin.cancelAll();
    if (!prefs.enabled) return;
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        texts.channel,
        color: const Color(0xFF4E5D52),
        category: AndroidNotificationCategory.reminder,
      ),
    );
    final now = tz.TZDateTime.now(tz.local);
    for (final day in prefs.days) {
      await _plugin.zonedSchedule(
        id: day,
        scheduledDate: nextOccurrence(now, day, prefs.hour, prefs.minute),
        notificationDetails: details,
        // Inexact is fine for a reminder and needs no "exact alarm" permission.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        title: texts.title,
        body: texts.body,
        payload: _payload,
        matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
      );
    }
  }

  @override
  Future<void> cancelAll() => _plugin.cancelAll();

  /// Next [day] of a month at [hour]:[minute] after [now].
  @visibleForTesting
  static tz.TZDateTime nextOccurrence(tz.TZDateTime now, int day, int hour, int minute) {
    final thisMonth = tz.TZDateTime(now.location, now.year, now.month, day, hour, minute);
    if (thisMonth.isAfter(now)) return thisMonth;
    final next = now.month == 12 ? (now.year + 1, 1) : (now.year, now.month + 1);
    return tz.TZDateTime(now.location, next.$1, next.$2, day, hour, minute);
  }
}
