class ScheduledTask {
  String id = '';
  final String title;
  final String description;
  final String cron;

  ScheduledTask({
    required this.title,
    required this.description,
    required this.cron,
  });

  factory ScheduledTask.fromMap(Map<String, dynamic> data) {
    var id = data['id'].toString() ?? '';
    var task = ScheduledTask(
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      cron: data['cron'] ?? '',
    );
    task.id = id;
    return task;
  }

  Map<String, dynamic> toMap() {
    return {'title': title, 'description': description, 'cron': cron};
  }
}
