/// Render a number the way JS does for these values: whole numbers without a
/// decimal point ("165"), others with their decimals trimmed ("3.6").
String fmtNum(num v, {int maxDecimals = 1}) {
  if (v.isNaN || v.isInfinite) return '0';
  final fixed = v.toStringAsFixed(maxDecimals);
  if (!fixed.contains('.')) return fixed;
  final trimmed = fixed.replaceFirst(RegExp(r'\.?0+$'), '');
  return trimmed == '-0' ? '0' : trimmed;
}

/// Round to one decimal place (JS `Math.round(v * 10) / 10`).
double round1(double v) => (v * 10).roundToDouble() / 10;
