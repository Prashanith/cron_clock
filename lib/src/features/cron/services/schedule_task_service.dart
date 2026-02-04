import 'package:sqflite/sqflite.dart';

import '../../../services/db_service.dart';
import '../../../services/init_services.dart';
import '../models/scheduled_task.dart';

class ScheduledTaskService {
  static Future<int> createTask(ScheduledTask task) async {
    var id = await locator<DbService>().db.insert(
      'cron',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  static Future<List<ScheduledTask>> getAllTasks() async {
    final List<Map<String, dynamic>> result = await locator<DbService>().db
        .query('cron', orderBy: 'id');

    return result.map((e) => ScheduledTask.fromMap(e)).toList();
  }

  static Future<ScheduledTask?> getTaskById(String id) async {
    final List<Map<String, dynamic>> result = await locator<DbService>().db
        .query('cron', where: 'id = ?', whereArgs: [id], limit: 1);

    if (result.isEmpty) return null;
    return ScheduledTask.fromMap(result.first);
  }

  static Future<int> updateTaskById(ScheduledTask task) async {
    return await locator<DbService>().db.update(
      'cron',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  static Future<int> deleteTaskById(String id) async {
    return await locator<DbService>().db.delete(
      'cron',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
