class CronDescriptionResult {
  final String inputText;
  final String? outputMessage;
  final String? errorMessage;

  const CronDescriptionResult({
    required this.inputText,
    this.outputMessage,
    this.errorMessage,
  });

  bool get isValid => errorMessage == null;
}

CronDescriptionResult describeCron(String cron) {
  final input = cron.trim();
  final parts = input.split(RegExp(r'\s+'));

  if (parts.length != 5) {
    return CronDescriptionResult(
      inputText: input,
      errorMessage: 'Cron expression must contain exactly 5 fields',
    );
  }

  final minute = parts[0];
  final hour = parts[1];
  final day = parts[2];
  final month = parts[3];
  final weekday = parts[4];

  final timeText = _timeText(minute, hour);
  final dayText = _dayText(day, weekday);
  final monthText = _monthText(month);

  final text = [
    timeText,
    dayText,
    monthText,
  ].where((e) => e.isNotEmpty).join(' ').trim();

  return CronDescriptionResult(inputText: input, outputMessage: text);
}

String _timeText(String minute, String hour) {
  if (_isNum(minute) && _isNum(hour)) {
    return 'At ${_pad(hour)}:${_pad(minute)}';
  }

  if (minute == '*' && hour == '*') {
    return 'At every minute';
  }

  if (minute.startsWith('*/') && hour == '*') {
    return 'Every ${minute.substring(2)} minutes';
  }

  if (hour.startsWith('*/') && minute == '*') {
    return 'Every minute every ${hour.substring(2)} hours';
  }

  if (minute == '*' && _isNum(hour)) {
    return 'At every minute during hour ${_pad(hour)}';
  }

  if (_isNum(minute) && hour == '*') {
    return 'At minute ${_pad(minute)} of every hour';
  }

  return 'At scheduled time';
}

String _dayText(String day, String weekday) {
  if (day == '*' && weekday == '*') {
    return '';
  }

  if (weekday != '*') {
    return 'on ${_weekdayText(weekday)}';
  }

  if (day != '*') {
    return 'on day $day';
  }

  return '';
}

String _monthText(String month) {
  if (month == '*') {
    return '';
  }

  if (month.startsWith('*/')) {
    return 'every ${month.substring(2)} months';
  }

  if (_isNum(month)) {
    final m = int.parse(month);
    return 'in ${monthNames[m] ?? 'month $m'}';
  }

  return '';
}

String _weekdayText(String value) {
  if (value.contains('-')) {
    final p = value.split('-');
    return '${weekdayNames[int.parse(p[0])]} to ${weekdayNames[int.parse(p[1])]}';
  }

  if (value.contains(',')) {
    return value.split(',').map((e) => weekdayNames[int.parse(e)]).join(', ');
  }

  if (_isNum(value)) {
    return weekdayNames[int.parse(value)]!;
  }

  return value;
}

bool _isNum(String s) => int.tryParse(s) != null;

String _pad(String s) => s.padLeft(2, '0');

const Map<int, String> monthNames = {
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

const Map<int, String> weekdayNames = {
  0: 'Sunday',
  1: 'Monday',
  2: 'Tuesday',
  3: 'Wednesday',
  4: 'Thursday',
  5: 'Friday',
  6: 'Saturday',
};
