import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AndroidAlarmService {
  final Future<SharedPreferences> secureStore = SharedPreferences.getInstance();

  void _checkExactAlarmPermission() async {
    final currentStatus = await Permission.scheduleExactAlarm.status;
    if (currentStatus.isDenied) {}
  }

  static void init() async {
    AndroidAlarmManager.initialize();
  }

  Future<void> setValue(String key, Object value) async {
    var s = await secureStore;
    switch (value.runtimeType) {
      case const (bool):
        s.setBool(key, value as bool);
        break;
      case const (String):
        s.setString(key, value as String);
        break;
      case const (int):
        s.setInt(key, value as int);
        break;
      case const (double):
        s.setDouble(key, value as double);
        break;
      default:
        s.setString(key, value as String);
    }
  }
}
