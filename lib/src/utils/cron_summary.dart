String describeCron(String cron) {
  final parts = cron.trim().split(RegExp(r'\s+'));
  if (parts.length != 5) {
    return 'Invalid cron: must contain 5 parts';
  }

  final minute = _describePart(parts[0], 'minute', 0, 59);
  final hour = _describePart(parts[1], 'hour', 0, 23);
  final day = _describePart(parts[2], 'day of month', 1, 31);
  final month = _describePart(parts[3], 'month', 1, 12, monthNames);
  final weekday = _describePart(parts[4], 'weekday', 0, 6, weekdayNames);

  return '''
Cron Expression Description:
- Runs at: $minute
- At hour: $hour
- On day: $day
- In month: $month
- On weekday: $weekday
''';
}

final monthNames = {
  1: 'January',
  2: 'February',
  3: 'March',
  4: 'April',
  5: 'May',
  6: 'June',
  7: 'July',
  8: 'August',
  9: 'September',
  10: 'October',
  11: 'November',
  12: 'December',
};

final weekdayNames = {
  0: 'Sunday',
  1: 'Monday',
  2: 'Tuesday',
  3: 'Wednesday',
  4: 'Thursday',
  5: 'Friday',
  6: 'Saturday',
};

String _describePart(
  String value,
  String label,
  int min,
  int max, [
  Map<int, String>? names,
]) {
  value = value.trim();

  if (value == '*') return 'every $label';

  // Step */5 or 10/5 or 5-10/2
  if (value.contains('/')) {
    final parts = value.split('/');
    final base = parts[0];
    final step = parts[1];
    if (base == '*') return 'every $step $label(s)';
    return 'every $step $label(s) starting at $base';
  }

  // Range 5-20
  if (value.contains('-')) {
    final r = value.split('-');
    final start = int.parse(r[0]);
    final end = int.parse(r[1]);
    return '${labelsFromNames(start, names)} to ${labelsFromNames(end, names)}';
  }

  // List 1,5,10
  if (value.contains(',')) {
    final items = value.split(',');
    return items.map((e) => labelsFromNames(int.parse(e), names)).join(', ');
  }

  // single numeric or name
  final n = int.tryParse(value);
  if (n != null) return labelsFromNames(n, names);

  return value; // fallback text
}

String labelsFromNames(int n, Map<int, String>? names) {
  if (names != null && names.containsKey(n)) {
    return names[n]!;
  }
  return n.toString();
}
