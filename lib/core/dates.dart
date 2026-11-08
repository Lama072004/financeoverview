/// Date helpers. All business dates in the app are calendar days without a
/// time component, so every value is normalised to local midnight.
library;

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime today() => dateOnly(DateTime.now());

/// Whole days from [from] to [to], immune to daylight-saving shifts.
int daysBetween(DateTime from, DateTime to) => DateTime.utc(to.year, to.month, to.day)
    .difference(DateTime.utc(from.year, from.month, from.day))
    .inDays;

DateTime firstOfMonth(DateTime d) => DateTime(d.year, d.month);

DateTime lastOfMonth(DateTime d) => DateTime(d.year, d.month + 1, 0);

String encodeDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime decodeDate(String s) {
  final parts = s.split('-');
  return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
}

DateTime? decodeDateOrNull(Object? s) => s is String && s.isNotEmpty ? decodeDate(s) : null;

bool isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
