import 'package:intl/intl.dart';

/// Returns the decimal separator character for [locale] (e.g. ',' for 'de').
String decimalSepForLocale(String locale) =>
    NumberFormat.decimalPattern(locale).symbols.DECIMAL_SEP;

/// Formats a quantity value.
/// Whole numbers omit the decimal point; trailing zeros are stripped.
/// Pass [decimalSep] to use a locale-specific separator (default: '.').
String fmtQty(double v, {String decimalSep = '.'}) {
  if (v == v.truncateToDouble()) return v.toInt().toString();
  final s = v.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
  return decimalSep == '.' ? s : s.replaceAll('.', decimalSep);
}
