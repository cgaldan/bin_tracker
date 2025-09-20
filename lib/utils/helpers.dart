String formatSeconds(int seconds) {
  final isNegative = seconds < 0;
  final dur = Duration(seconds: seconds.abs());
  final days = dur.inDays;
  final hours = dur.inHours.remainder(24);
  final minutes = dur.inMinutes.remainder(60);
  final secs = dur.inSeconds.remainder(60);

  final hoursStr = hours.toString().padLeft(2, '0');
  final minutesStr = minutes.toString().padLeft(2, '0');
  final secsStr = secs.toString().padLeft(2, '0');

  if (days > 0) {
    final dayText = days == 1 ? 'day' : 'days';
    return '${isNegative ? '-' : ''}$days $dayText $hoursStr:$minutesStr:$secsStr';
  } else if (hours > 0) {
    final hourText = hours == 1 ? 'hour' : 'hours';
    return '${isNegative ? '-' : ''}$hours $hourText $minutesStr:$secsStr';
  } else {
    return '${isNegative ? '-' : ''}$minutesStr:$secsStr';
  }
}

String formatPlannedDuration(int seconds) {
  final dur = Duration(seconds: seconds);
  final days = dur.inDays;
  final hours = dur.inHours.remainder(24);

  if (days > 0) {
    final dayText = days == 1 ? 'day' : 'days';
    if (hours > 0) {
      final hourText = hours == 1 ? 'hour' : 'hours';
      return '$days $dayText $hours $hourText';
    } else {
      return '$days $dayText';
    }
  } else if (hours > 0) {
    final hourText = hours == 1 ? 'hour' : 'hours';
    return '$hours $hourText';
  } else {
    final minutes = dur.inMinutes;
    final minuteText = minutes == 1 ? 'minute' : 'minutes';
    return '$minutes $minuteText';
  }
}
