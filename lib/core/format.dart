import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Discreet mode: every amount below is shown as "•••• €".
class Discreet extends InheritedWidget {
  const Discreet({super.key, required this.hidden, required super.child});

  final bool hidden;

  static bool of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<Discreet>()?.hidden ?? false;

  @override
  bool updateShouldNotify(Discreet oldWidget) => hidden != oldWidget.hidden;
}

/// Locale-aware formatting of amounts, percentages and dates.
///
/// With [hidden] (discreet mode) amounts are masked; percentages and dates
/// stay visible because they reveal nothing about the size of the wealth.
class Fmt {
  Fmt(this.locale, {this.hidden = false})
      : _money = NumberFormat.currency(locale: locale, symbol: '€', decimalDigits: 2),
        _moneyRound = NumberFormat.currency(locale: locale, symbol: '€', decimalDigits: 0),
        _number = NumberFormat.decimalPatternDigits(locale: locale, decimalDigits: 2),
        _plain = NumberFormat('0.##########', locale),
        _percent = NumberFormat.decimalPercentPattern(locale: locale, decimalDigits: 1),
        _percentRound = NumberFormat.decimalPercentPattern(locale: locale, decimalDigits: 0),
        _date = DateFormat.yMMMd(locale),
        _dateShort = DateFormat.yMd(locale),
        _dayMonth = DateFormat.MMMd(locale),
        _month = DateFormat.yMMMM(locale),
        _monthShort = DateFormat.MMM(locale),
        _time = DateFormat.Hm(locale);

  factory Fmt.of(BuildContext context) =>
      Fmt(Localizations.localeOf(context).toLanguageTag(), hidden: Discreet.of(context));

  static const dots = '••••';

  final String locale;
  final bool hidden;
  final NumberFormat _money;
  final NumberFormat _moneyRound;
  final NumberFormat _number;
  final NumberFormat _plain;
  final NumberFormat _percent;
  final NumberFormat _percentRound;
  final DateFormat _date;
  final DateFormat _dateShort;
  final DateFormat _dayMonth;
  final DateFormat _month;
  final DateFormat _monthShort;
  final DateFormat _time;

  String get decimalSeparator => _number.symbols.DECIMAL_SEP;

  /// "•••• €" / "€••••".
  String get _masked => _money.format(0).replaceFirst(RegExp(r'0\D00'), dots);

  /// "1.234,56 €" – avoids "-0,00 €" and uses a real minus sign.
  String money(double v) => hidden ? _masked : _minus(_money.format(_clean(v)));

  /// Amount with an explicit sign: "+12,30 €" / "−12,30 €".
  String signedMoney(double v) {
    if (hidden) return _masked;
    final c = _clean(v);
    if (c == 0) return _money.format(0);
    return '${c > 0 ? '+' : '−'}${_money.format(c.abs())}';
  }

  /// Whole euros with an explicit sign: "+12 €" / "−12 €".
  String signedMoneyRound(double v) {
    if (hidden) return _masked;
    final c = _clean(v).roundToDouble();
    if (c == 0) return _moneyRound.format(0);
    return '${c > 0 ? '+' : '−'}${_moneyRound.format(c.abs())}';
  }

  /// Whole euros, for compact cards and chart axes.
  String moneyRound(double v) => hidden ? _masked : _minus(_moneyRound.format(_clean(v).roundToDouble()));

  /// Short axis labels: "850", "12k", "1,2M".
  String compact(double v) {
    if (hidden) return '••';
    final a = _clean(v).abs();
    final sign = v < 0 ? '−' : '';
    if (a >= 1e6) return '$sign${number(a / 1e6, decimals: a >= 1e7 ? 0 : 1)}M';
    if (a >= 1e3) return '$sign${number(a / 1e3, decimals: a >= 1e4 ? 0 : 1)}k';
    return '$sign${number(a, decimals: 0)}';
  }

  /// Label of an amount axis: whole numbers when the steps are small.
  String axis(double v, {required bool fine}) => hidden ? '••' : (fine ? number(v, decimals: 0) : compact(v));

  String number(double v, {int decimals = 2}) =>
      _minus(NumberFormat.decimalPatternDigits(locale: locale, decimalDigits: decimals).format(_clean(v)));

  /// For editable fields: no grouping, minimal decimals.
  String plain(double v) => _plain.format(v);

  String percent(double v) => _minus(_percent.format(v.abs() < 0.00005 ? 0 : v));

  String percentRound(double v) => _minus(_percentRound.format(v.abs() < 0.0005 ? 0 : v));

  String date(DateTime d) => _date.format(d);

  String dateShort(DateTime d) => _dateShort.format(d);

  String dayMonth(DateTime d) => _dayMonth.format(d);

  String month(DateTime d) => _month.format(d);

  String monthShort(DateTime d) => _monthShort.format(d);

  String time(DateTime d) => _time.format(d);

  static double _clean(double v) => v.abs() < 0.005 ? 0 : v;

  static String _minus(String s) => s.replaceFirst('-', '−');
}

/// Parses user input such as "1.234,56", "1234.56", "-12", "12,5 %".
/// Returns null for empty or invalid input.
double? parseAmount(String input) {
  var s = input.trim().replaceAll(RegExp(r'[\s€%  ]'), '').replaceAll('−', '-');
  if (s.isEmpty) return null;
  final lastComma = s.lastIndexOf(',');
  final lastDot = s.lastIndexOf('.');
  if (lastComma >= 0 && lastDot >= 0) {
    // Both present: the last one is the decimal separator.
    if (lastComma > lastDot) {
      s = s.replaceAll('.', '').replaceAll(',', '.');
    } else {
      s = s.replaceAll(',', '');
    }
  } else if (lastComma >= 0) {
    s = s.replaceAll(',', '.');
  }
  if (s.indexOf('.') != s.lastIndexOf('.')) {
    // "1.234.567" → grouping dots.
    s = s.replaceAll('.', '');
  }
  return double.tryParse(s);
}
