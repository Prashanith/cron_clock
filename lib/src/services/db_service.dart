import 'package:sqflite/sqflite.dart';

class DbService {
  late Database db;

  Future<void> createDatabase() async {
    db = await openDatabase(
      'cron_clock.db',
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE cron (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            cron TEXT,
            lastScheduledAt DATETIME        
          )
          ''');
      },
    );
  }
}
