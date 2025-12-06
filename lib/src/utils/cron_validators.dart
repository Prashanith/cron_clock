String? validateCronExpression(String? cron) {
  if (cron == null || cron.trim().isEmpty) {
    return 'Cron expression is required';
  }

  final parts = cron.trim().split(RegExp(r'\s+'));
  if (parts.length != 5) {
    return 'Cron must have exactly 5 fields: minute hour day month weekday';
  }

  final validators = [
    {'min': 0, 'max': 59, 'names': null}, // minute
    {'min': 0, 'max': 23, 'names': null}, // hour
    {'min': 1, 'max': 31, 'names': null}, // day of month
    {
      'min': 1,
      'max': 12,
      'names': [
        'JAN',
        'FEB',
        'MAR',
        'APR',
        'MAY',
        'JUN',
        'JUL',
        'AUG',
        'SEP',
        'OCT',
        'NOV',
        'DEC',
      ],
    }, // month
    {
      'min': 0,
      'max': 6,
      'names': ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'],
    }, // weekday
  ];

  for (int i = 0; i < 5; i++) {
    String value = parts[i];
    int min = validators[i]['min'] as int;
    int max = validators[i]['max'] as int;
    List<String>? names = validators[i]['names'] as List<String>?;

    String? error = _validateCronField(value, min, max, names: names);
    if (error != null) {
      return 'Field ${i + 1}: $error';
    }
  }

  return null; // valid
}

/// Internal shared validator for each cron field
String? _validateCronField(
  String value,
  int min,
  int max, {
  List<String>? names,
}) {
  final v = value.trim();
  if (v == '*') return null;

  for (final part in v.split(',')) {
    final p = part.trim().toUpperCase();

    // Name support
    if (names != null && names.contains(p)) continue;

    // Range (x-y)
    if (p.contains('-')) {
      final r = p.split('-');
      if (r.length != 2) return 'Invalid range "$p"';
      final start = int.tryParse(r[0]);
      final end = int.tryParse(r[1]);
      if (start == null || end == null) return 'Invalid number in "$p"';
      if (start < min || end > max) return 'Range must be $min–$max';
      continue;
    }

    // Step (x/y or */y)
    if (p.contains('/')) {
      final s = p.split('/');
      if (s.length != 2) return 'Invalid step "$p"';

      final base = s[0];
      final step = int.tryParse(s[1]);
      if (step == null || step < 1) return 'Invalid step value in "$p"';

      if (base != '*') {
        final baseNum = int.tryParse(base);
        if (baseNum == null || baseNum < min || baseNum > max) {
          return 'Base value "$base" must be $min–$max';
        }
      }

      continue;
    }

    // Single number
    final numVal = int.tryParse(p);
    if (numVal == null || numVal < min || numVal > max) {
      return 'Value "$p" must be $min–$max';
    }
  }

  return null;
}

String? validateCronMinute(String? value) {
  if (value == null || value.trim().isEmpty) return 'Minute required';
  final v = value.trim();
  if (v == '*') return null;

  for (final part in v.split(',')) {
    final p = part.trim();

    if (p.contains('-')) {
      final r = p.split('-');
      if (r.length != 2) return 'Invalid minute range';
      final start = int.tryParse(r[0]);
      final end = int.tryParse(r[1]);
      if (start == null || end == null) return 'Invalid minute number';
      if (start < 0 || end > 59) return 'Minute must be 0–59';
      continue;
    }

    if (p.contains('/')) {
      final s = p.split('/');
      if (s.length != 2) return 'Invalid minute step';
      final step = int.tryParse(s[1]);
      if (step == null || step < 1) return 'Invalid minute step value';

      final base = s[0];
      if (base != '*') {
        final b = int.tryParse(base);
        if (b == null || b < 0 || b > 59) return 'Minute must be 0–59';
      }
      continue;
    }

    final n = int.tryParse(p);
    if (n == null || n < 0 || n > 59) return 'Minute must be 0–59';
  }

  return null;
}

// 2) Hour (0–23)
String? validateCronHour(String? value) {
  if (value == null || value.trim().isEmpty) return 'Hour required';
  final v = value.trim();
  if (v == '*') return null;

  for (final part in v.split(',')) {
    final p = part.trim();

    if (p.contains('-')) {
      final r = p.split('-');
      if (r.length != 2) return 'Invalid hour range';
      final start = int.tryParse(r[0]);
      final end = int.tryParse(r[1]);
      if (start == null || end == null) return 'Invalid hour number';
      if (start < 0 || end > 23) return 'Hour must be 0–23';
      continue;
    }

    if (p.contains('/')) {
      final s = p.split('/');
      if (s.length != 2) return 'Invalid hour step';
      final step = int.tryParse(s[1]);
      if (step == null || step < 1) return 'Invalid hour step value';

      final base = s[0];
      if (base != '*') {
        final b = int.tryParse(base);
        if (b == null || b < 0 || b > 23) return 'Hour must be 0–23';
      }
      continue;
    }

    final n = int.tryParse(p);
    if (n == null || n < 0 || n > 23) return 'Hour must be 0–23';
  }

  return null;
}

// 3) Day of Month (1–31)
String? validateCronDayOfMonth(String? value) {
  if (value == null || value.trim().isEmpty) return 'Day of month required';
  final v = value.trim();
  if (v == '*') return null;

  for (final part in v.split(',')) {
    final p = part.trim();

    if (p.contains('-')) {
      final r = p.split('-');
      if (r.length != 2) return 'Invalid DOM range';
      final start = int.tryParse(r[0]);
      final end = int.tryParse(r[1]);
      if (start == null || end == null) return 'Invalid DOM number';
      if (start < 1 || end > 31) return 'Day must be 1–31';
      continue;
    }

    if (p.contains('/')) {
      final s = p.split('/');
      if (s.length != 2) return 'Invalid DOM step';
      final step = int.tryParse(s[1]);
      if (step == null || step < 1) return 'Invalid DOM step value';

      final base = s[0];
      if (base != '*') {
        final b = int.tryParse(base);
        if (b == null || b < 1 || b > 31) return 'Day must be 1–31';
      }
      continue;
    }

    final n = int.tryParse(p);
    if (n == null || n < 1 || n > 31) return 'Day must be 1–31';
  }

  return null;
}

// 4) Month (1–12 or JAN–DEC)
String? validateCronMonth(String? value) {
  if (value == null || value.trim().isEmpty) return 'Month required';
  final v = value.trim();
  if (v == '*') return null;

  final monthNames = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ];

  for (final part in v.split(',')) {
    final p = part.trim().toUpperCase();

    if (monthNames.contains(p)) continue;

    if (p.contains('-')) {
      final r = p.split('-');
      if (r.length != 2) return 'Invalid month range';
      final start = int.tryParse(r[0]);
      final end = int.tryParse(r[1]);
      if (start == null || end == null) return 'Invalid month number';
      if (start < 1 || end > 12) return 'Month must be 1–12';
      continue;
    }

    if (p.contains('/')) {
      final s = p.split('/');
      if (s.length != 2) return 'Invalid month step';
      final step = int.tryParse(s[1]);
      if (step == null || step < 1) return 'Invalid month step value';

      final base = s[0];
      if (base != '*') {
        final b = int.tryParse(base);
        if (b == null || b < 1 || b > 12) return 'Month must be 1–12';
      }
      continue;
    }

    final n = int.tryParse(p);
    if (n == null || n < 1 || n > 12) {
      return 'Month must be 1–12 or JAN–DEC';
    }
  }

  return null;
}

// 5) Day of Week (0–6 or SUN–SAT)
String? validateCronDayOfWeek(String? value) {
  if (value == null || value.trim().isEmpty) return 'Day of week required';
  final v = value.trim();
  if (v == '*') return null;

  final weekNames = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

  for (final part in v.split(',')) {
    final p = part.trim().toUpperCase();

    if (weekNames.contains(p)) continue;

    if (p.contains('-')) {
      final r = p.split('-');
      if (r.length != 2) return 'Invalid weekday range';
      final start = int.tryParse(r[0]);
      final end = int.tryParse(r[1]);
      if (start == null || end == null) return 'Invalid weekday number';
      if (start < 0 || end > 6) return 'Weekday must be 0–6';
      continue;
    }

    if (p.contains('/')) {
      final s = p.split('/');
      if (s.length != 2) return 'Invalid weekday step';
      final step = int.tryParse(s[1]);
      if (step == null || step < 1) return 'Invalid weekday step value';

      final base = s[0];
      if (base != '*') {
        final b = int.tryParse(base);
        if (b == null || b < 0 || b > 6) return 'Weekday must be 0–6';
      }
      continue;
    }

    final n = int.tryParse(p);
    if (n == null || n < 0 || n > 6) {
      return 'Weekday must be 0–6 or SUN–SAT';
    }
  }

  return null;
}
