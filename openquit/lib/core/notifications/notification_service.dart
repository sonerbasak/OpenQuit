import 'package:flutter/material.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../milestones/milestone.dart';

@lazySingleton
class NotificationService {
  static const String _channelMotivation = 'oq_motivation';
  static const String _channelMilestone = 'oq_milestone';
  static const int _dailyNotifId = 9001;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ─── Init ──────────────────────────────────────────────────────────────────

  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    _setLocalTimezone();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    await _createChannels();
    _initialized = true;
  }

  void _setLocalTimezone() {
    try {
      final offsetMinutes = DateTime.now().timeZoneOffset.inMinutes;
      // Etc/GMT ters işaret kullanır: UTC+3 → Etc/GMT-3
      final hours = (offsetMinutes / 60).truncate();
      final tzName = 'Etc/GMT${hours > 0 ? '-' : '+'}${hours.abs()}';
      try {
        tz.setLocalLocation(tz.getLocation(tzName));
        return;
      } catch (_) {}
      // Fallback: UTC
      tz.setLocalLocation(tz.UTC);
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
  }

  Future<void> _createChannels() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return;

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelMotivation,
        'Daily Motivation',
        description: 'Daily motivational reminders',
        importance: Importance.defaultImportance,
      ),
    );
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelMilestone,
        'Milestone Celebrations',
        description: 'Celebrate sobriety milestones',
        importance: Importance.high,
      ),
    );
  }

  // ─── Permission ────────────────────────────────────────────────────────────

  /// İzin ister. Bildirim izni yeterliyse true döner.
  /// Exact alarm izni ayrı — olmasa bile bildirim gönderebiliriz (inexact).
  Future<bool> requestPermission() async {
    if (!_initialized) await init();

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final iosPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      // Bildirim izni — Android 13+ zorunlu
      final notifGranted =
          await androidPlugin.requestNotificationsPermission();
      if (notifGranted == false) return false;

      // Exact alarm izni — isteğe bağlı, olmasa inexact kullanırız
      // null dönerse cihaz desteklemiyor demektir, sorun değil
      await androidPlugin.requestExactAlarmsPermission();

      return true;
    }

    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  /// Exact alarm izninin verilip verilmediğini kontrol eder.
  Future<bool> _hasExactAlarmPermission() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return true;
    try {
      final canSchedule = await androidPlugin.canScheduleExactNotifications();
      return canSchedule ?? false;
    } catch (_) {
      return false;
    }
  }

  // ─── Daily motivation ──────────────────────────────────────────────────────

  Future<void> scheduleDailyMotivation({
    required int hour,
    required int minute,
  }) async {
    if (!_initialized) await init();

    await _plugin.cancel(_dailyNotifId);

    final now = DateTime.now();
    var scheduled = DateTime(now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    final tzScheduled = tz.TZDateTime.from(scheduled, tz.local);
    final quote = _randomMotivation();

    // Exact alarm varsa exact, yoksa inexact kullan — her ikisi de çalışır
    final hasExact = await _hasExactAlarmPermission();
    final scheduleMode = hasExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    await _plugin.zonedSchedule(
      _dailyNotifId,
      '💪 Stay strong today!',
      quote,
      tzScheduled,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelMotivation,
          'Daily Motivation',
          channelDescription: 'Daily motivational reminders',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          styleInformation: BigTextStyleInformation(quote),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: scheduleMode,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelDailyMotivation() async {
    await _plugin.cancel(_dailyNotifId);
  }

  // ─── Milestone ─────────────────────────────────────────────────────────────

  Future<void> showMilestone({
    required Milestone milestone,
    required String addictionName,
  }) async {
    if (!_initialized) await init();

    await _plugin.show(
      milestone.id.hashCode.abs() % 10000,
      '${milestone.emoji} $addictionName — ${milestone.label}!',
      milestone.message,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelMilestone,
          'Milestone Celebrations',
          channelDescription: 'Celebrate sobriety milestones',
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(milestone.message),
          color: const Color(0xFF7C5CFC),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
    );
  }

  // ─── Test ──────────────────────────────────────────────────────────────────

  Future<void> sendTestNotification() async {
    if (!_initialized) await init();

    await _plugin.show(
      9999,
      '✅ Notifications are working!',
      'OpenQuit notifications are set up correctly.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelMotivation,
          'Daily Motivation',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
    );
  }

  // ─── Quotes ────────────────────────────────────────────────────────────────

  static const List<String> _quotes = [
    'Every day sober is a victory. Keep going!',
    'You are stronger than your cravings.',
    'One day at a time. You\'ve got this.',
    'Your future self is proud of you.',
    'The pain of discipline is less than the pain of regret.',
    'Recovery is not a race. You don\'t have to feel guilty if it takes time.',
    'You didn\'t come this far to only come this far.',
    'Small steps every day lead to big changes.',
    'Believe in yourself. You\'ve survived 100% of your bad days.',
    'Today is another chance to be the person you want to be.',
    'Your sobriety is your superpower.',
    'Progress, not perfection.',
    'The best time to start was yesterday. The second best time is now.',
    'You are rewriting your story, one sober day at a time.',
    'Strength doesn\'t come from what you can do. It comes from overcoming what you thought you couldn\'t.',
  ];

  static String _randomMotivation() {
    final idx = DateTime.now().millisecondsSinceEpoch % _quotes.length;
    return _quotes[idx];
  }
}
