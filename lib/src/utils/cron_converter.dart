class CronUtils {
  static DateTime? computeNextRun(String cron) {
    final parts = cron.trim().split(RegExp(r'\s+'));
    if (parts.length != 5) return null;

    final minuteSet = _parseField(parts[0], 0, 59);
    final hourSet = _parseField(parts[1], 0, 23);
    final domSet = _parseField(parts[2], 1, 31);
    final monthSet = _parseField(parts[3], 1, 12);
    final dowSet = _parseField(parts[4], 0, 6);

    if ([minuteSet, hourSet, domSet, monthSet, dowSet].any((e) => e.isEmpty)) {
      return null;
    }

    DateTime candidate = DateTime.now()
        .add(const Duration(minutes: 1))
        .copyWith(second: 0);

    for (int i = 0; i < 525600; i++) {
      if (_matches(candidate, minuteSet, hourSet, domSet, monthSet, dowSet)) {
        return candidate;
      }
      candidate = candidate.add(const Duration(minutes: 1));
    }

    return null;
  }

  static bool _matches(
    DateTime dt,
    Set<int> minute,
    Set<int> hour,
    Set<int> dom,
    Set<int> month,
    Set<int> dow,
  ) {
    return minute.contains(dt.minute) &&
        hour.contains(dt.hour) &&
        month.contains(dt.month) &&
        dom.contains(dt.day) &&
        dow.contains(dt.weekday % 7);
  }

  static Set<int> _parseField(String expr, int min, int max) {
    final result = <int>{};

    for (final part in expr.split(',')) {
      if (part.contains('/')) {
        final split = part.split('/');
        final base = split[0];
        final step = int.tryParse(split[1]);
        if (step == null || step <= 0) return {};

        final range = base == '*'
            ? [min, max]
            : base.contains('-')
            ? base.split('-').map(int.parse).toList()
            : [int.parse(base), max];

        for (int i = range[0]; i <= range[1]; i += step) {
          if (i >= min && i <= max) result.add(i);
        }
      } else if (part.contains('-')) {
        final r = part.split('-').map(int.parse).toList();
        for (int i = r[0]; i <= r[1]; i++) {
          if (i >= min && i <= max) result.add(i);
        }
      } else if (part == '*') {
        for (int i = min; i <= max; i++) {
          result.add(i);
        }
      } else {
        final v = int.tryParse(part);
        if (v == null || v < min || v > max) return {};
        result.add(v);
      }
    }

    return result;
  }
}
