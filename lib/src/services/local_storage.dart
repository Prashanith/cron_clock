import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  final Future<SharedPreferences> secureStore = SharedPreferences.getInstance();

  Future<Object?> getValue(String key) async {
    var s = await secureStore;
    return s.get(key);
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
