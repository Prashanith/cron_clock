import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'init_services.dart';

class NotificationService {
  NotificationService();
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      locator<FlutterLocalNotificationsPlugin>();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'alarm_channel_v5',
    'Alarm_Notifications',
    description: 'Notifications for alarms and reminders',
    importance: Importance.max,
    playSound: true,
    bypassDnd: false,
    enableVibration: true,
    enableLights: true,
    audioAttributesUsage: AudioAttributesUsage.notification,
  );

  Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);
  }

  Future<void> show({
    required int id,
    required String title,
    required String body,
  }) async {
    await _plugin.show(id, title, body, _notificationDetails());
  }

  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
  }) async {
    var time = tz.TZDateTime.from(
      dateTime.toLocal(),
      tz.getLocation('Asia/Kolkata'),
    );
    await _plugin.zonedSchedule(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      time,
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: time.toString(),
    );
  }

  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  Future<List<PendingNotificationRequest>> getAll() async {
    return _plugin.pendingNotificationRequests();
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  NotificationDetails _notificationDetails() {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        fullScreenIntent: true,
        onlyAlertOnce: false,
        audioAttributesUsage: AudioAttributesUsage.notification,
      ),
    );
  }

  static void _onNotificationTap(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.id}');
  }
}
