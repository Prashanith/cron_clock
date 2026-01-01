import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AlarmEngine {
  AlarmEngine._private();

  static final AlarmEngine instance = AlarmEngine._private();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final AudioPlayer audioPlayer = AudioPlayer();

  /// mapping id -> label for notification
  final Map<int, String> labels = {};

  Future<void> initialize() async {
    // Init notifications
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await flutterLocalNotificationsPlugin.initialize(initSettings);

    // Preload or set audio settings if needed
  }

  Future<void> showNotificationAndPlaySound(int id) async {
    // Show local notification
    const androidDetails = AndroidNotificationDetails(
      'cron_alarm_ch',
      'Cron Alarms',
      channelDescription: 'cron alarm channel',
      importance: Importance.max,
      priority: Priority.high,
      playSound: false,
      fullScreenIntent: true,
    );
    const details = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      id,
      labels[id] ?? 'Cron Alarm',
      'Alarm fired at ${DateTime.now()}',
      details,
    );

    // play a short beep (package plays from network/local; here we play a system tone by generating)
    try {
      // You can use a local asset: audioPlayer.play(AssetSource('sounds/alarm.mp3'));
      // For simplicity we play a short beep using the players' low-level API (some platforms may need assets)
      // Please add an audio asset in a real app.
      await audioPlayer.play(
        AssetSource('sounds/alarm_short.mp3'),
        volume: 1.0,
      );
    } catch (e) {
      // ignore if not available — notification is primary
    }
  }

  /// Called after the alarm fired to schedule the next occurrence for the same cron expression.
  /// This demo assumes you stored mapping from id -> cron (we stored into MyApp state's map).
  Future<void> rescheduleNextForId(int id) async {
    // IMPORTANT: In this demo the mapping id->cron is in memory inside the page.
    // In production you must persist cron->id mapping in persistent storage (SharedPreferences/DB)
    // so the background isolate can read it here. Because this callback runs in a background isolate,
    // accessing memory in the UI isolate will NOT work.
    //
    // For the demo, we do nothing. In a real app:
    // 1) persist (id -> cron) in shared_preferences or sqlite
    // 2) here read the cron expression for the id from shared_preferences
    // 3) compute next run and schedule another AndroidAlarmManager.oneShotAt(next, id, alarmCallback ...)
    //
    // Example pseudo:
    // final cron = await readCronFromPrefs(id);
    // final next = CronUtils.computeNextRun(cron);
    // if (next != null) AndroidAlarmManager.oneShotAt(next, id, alarmCallback, ...);

    // left empty intentionally in demo
  }
}

/// A very small cron helper to compute the next DateTime for simple/commonly-used expressions.
///
/// Supported patterns (examples):
/// - "*/N * * * *" -> every N minutes (N between 1 and 59)
/// - "M H * * *" -> every day at hour H and minute M (M in 0..59, H in 0..23)
/// - "M H * * W" -> specific weekday (0-6)
/// - simple lists like "5,15,30 * * * *" (minute list)
///
/// NOTE: This is a simplified parser for demo purposes. Replace with a complete cron parser if you need
/// full cron syntax support (names, ranges + steps + combined edge cases).
class CronUtils {
  /// Returns the next DateTime (local) when the cron should run, or null if unsupported.
  static DateTime? computeNextRun(String cron) {
    final parts = cron.trim().split(RegExp(r'\s+'));
    if (parts.length != 5) return null;

    final minuteExpr = parts[0];
    final hourExpr = parts[1];
    final domExpr = parts[2];
    final monExpr = parts[3];
    final dowExpr = parts[4];

    final now = DateTime.now();

    // Shortcut: handles "*/N * * * *" (every N minutes)
    final stepMatch = RegExp(r'^\*/(\d{1,2})$').firstMatch(minuteExpr);
    if (stepMatch != null) {
      final step = int.tryParse(stepMatch.group(1)!)!;
      if (step < 1 || step > 59) return null;
      // compute next multiple-of-step minute
      final nextMinute = ((now.minute ~/ step) + 1) * step;
      var candidate = DateTime(
        now.year,
        now.month,
        now.day,
        now.hour,
        nextMinute % 60,
      );
      if (nextMinute >= 60) {
        candidate = DateTime(
          now.year,
          now.month,
          now.day,
          now.hour + 1,
          nextMinute % 60,
        );
      }
      if (!candidate.isAfter(now)) {
        candidate = candidate.add(const Duration(minutes: 1));
      }
      return candidate;
    }

    // If minute is a single number (or list), and hour is '*' -> next occurrence this hour/day
    // For reliability, we will handle two common formats:
    // 1) "M H * * *" -> daily at specific hour/minute
    final singleMinute = _singleNumberOrListToNumbers(minuteExpr, 0, 59);
    final singleHour = _singleNumberOrListToNumbers(hourExpr, 0, 23);
    final domAny = domExpr == '*' ? true : false;
    final monAny = monExpr == '*' ? true : false;
    final dowAny = dowExpr == '*' ? true : false;

    // If both minute and hour are specific numbers (or lists), schedule the next occurrence from lists
    if (singleMinute.isNotEmpty &&
        singleHour.isNotEmpty &&
        domAny &&
        monAny &&
        dowAny) {
      // generate a set of candidate DateTimes starting from now and return the soonest after now
      final List<DateTime> candidates = [];
      for (final h in singleHour) {
        for (final m in singleMinute) {
          var dt = DateTime(now.year, now.month, now.day, h, m);
          if (!dt.isAfter(now)) dt = dt.add(const Duration(days: 1));
          candidates.add(dt);
        }
      }
      candidates.sort((a, b) => a.compareTo(b));
      return candidates.isEmpty ? null : candidates.first;
    }

    // As fallback: if minute expr is single int and hour is "*", schedule the next time that minute occurs
    if (singleMinute.isNotEmpty &&
        hourExpr == '*' &&
        domAny &&
        monAny &&
        dowAny) {
      final m = singleMinute.first;
      var candidate = DateTime(now.year, now.month, now.day, now.hour, m);
      if (!candidate.isAfter(now))
        candidate = candidate.add(const Duration(hours: 1));
      return candidate;
    }

    // Unsupported complex cron in this simple demo
    return null;
  }

  // helper: accepts single number, or comma-separated numbers; returns list of ints or empty if not simple
  static List<int> _singleNumberOrListToNumbers(String expr, int min, int max) {
    final parts = expr.split(',');
    final out = <int>[];
    for (final p in parts) {
      final s = p.trim();
      if (s.isEmpty) return [];
      // only allow a single integer (no ranges, no steps)
      final n = int.tryParse(s);
      if (n == null) return [];
      if (n < min || n > max) return [];
      out.add(n);
    }
    return out;
  }
}
