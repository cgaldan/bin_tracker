String formatSeconds(int seconds) {
  final isNegative = seconds < 0;
  final dur = Duration(seconds: seconds.abs());
  final days = dur.inDays;
  final hours = dur.inHours.remainder(24).toString().padLeft(2, '0');
  final minutes = dur.inMinutes.remainder(60).toString().padLeft(2, '0');
  final secs = dur.inSeconds.remainder(60).toString().padLeft(2, '0');

  if (days > 0) {
    return '${isNegative ? '-' : ''}$days days $hours:$minutes:$secs';
  } else {
    return '${isNegative ? '-' : ''}$hours:$minutes:$secs';
  }
}
