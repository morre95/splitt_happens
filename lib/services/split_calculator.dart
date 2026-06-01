import '../models/bill.dart';
import '../models/receipt_parse_result.dart';

/// An exact non-negative rational number backed by [BigInt], used to keep
/// split arithmetic free of floating-point drift across many line items.
class _Rational {
  _Rational(BigInt numerator, BigInt denominator)
      : assert(denominator != BigInt.zero, 'denominator must be non-zero'),
        _num = _reduceNum(numerator, denominator),
        _den = _reduceDen(numerator, denominator);

  /// Creates a rational from an integer value.
  factory _Rational.fromInt(int value) =>
      _Rational(BigInt.from(value), BigInt.one);

  final BigInt _num;
  final BigInt _den;

  static final _Rational zero = _Rational.fromInt(0);

  static BigInt _reduceNum(BigInt n, BigInt d) {
    if (n == BigInt.zero) return BigInt.zero;
    final BigInt g = n.gcd(d);
    final BigInt sign = d.isNegative ? -BigInt.one : BigInt.one;
    return (n ~/ g) * sign;
  }

  static BigInt _reduceDen(BigInt n, BigInt d) {
    if (n == BigInt.zero) return BigInt.one;
    final BigInt g = n.gcd(d);
    return (d ~/ g).abs();
  }

  _Rational operator +(_Rational other) =>
      _Rational(_num * other._den + other._num * _den, _den * other._den);

  _Rational operator *(_Rational other) =>
      _Rational(_num * other._num, _den * other._den);

  _Rational operator /(_Rational other) =>
      _Rational(_num * other._den, _den * other._num);

  bool get isZero => _num == BigInt.zero;

  /// Rounds to the nearest integer (half-up), assuming a non-negative value.
  BigInt roundToBigInt() {
    final BigInt twiceRemainder = (_num % _den) * BigInt.two;
    final BigInt floor = _num ~/ _den;
    return twiceRemainder >= _den ? floor + BigInt.one : floor;
  }
}

/// Pure, stateless math for turning item assignments into per-person totals.
class SplitCalculator {
  /// Creates a [SplitCalculator].
  const SplitCalculator();

  /// Tolerance (in currency units) allowed when validating a parsed subtotal.
  static const double _subtotalTolerance = 0.02;

  /// Computes the final amount owed by each person.
  ///
  /// For every [Split], the person owes
  /// `unitPrice × quantity × portionNumerator / portionDenominator` of that
  /// item. [taxAmount] and [tipAmount] are then prorated across people in
  /// proportion to each person's item subtotal.
  ///
  /// Returns a map of `personId → finalAmount`, rounded to whole cents. Only
  /// people who own at least one split appear in the result.
  Map<String, double> calculate({
    required List<Item> items,
    required List<Split> splits,
    required double taxAmount,
    required double tipAmount,
  }) {
    // Line total of each item, in exact integer cents.
    final Map<String, int> lineCentsById = <String, int>{
      for (final Item item in items)
        item.id: (item.unitPrice * item.quantity * 100).round(),
    };

    // Accumulate each person's subtotal (in cents) as an exact rational.
    final Map<String, _Rational> subtotals = <String, _Rational>{};
    for (final Split split in splits) {
      final int? lineCents = lineCentsById[split.itemId];
      if (lineCents == null || split.portionDenominator == 0) continue;
      final _Rational share = _Rational(
        BigInt.from(lineCents) * BigInt.from(split.portionNumerator),
        BigInt.from(split.portionDenominator),
      );
      subtotals[split.personId] =
          (subtotals[split.personId] ?? _Rational.zero) + share;
    }

    final _Rational totalSubtotal = subtotals.values
        .fold(_Rational.zero, (_Rational sum, _Rational s) => sum + s);

    final _Rational taxCents = _Rational.fromInt((taxAmount * 100).round());
    final _Rational tipCents = _Rational.fromInt((tipAmount * 100).round());

    final Map<String, double> result = <String, double>{};
    for (final MapEntry<String, _Rational> entry in subtotals.entries) {
      _Rational finalCents = entry.value;
      if (!totalSubtotal.isZero) {
        final _Rational shareRatio = entry.value / totalSubtotal;
        finalCents = finalCents + taxCents * shareRatio + tipCents * shareRatio;
      }
      result[entry.key] = finalCents.roundToBigInt().toInt() / 100.0;
    }
    return result;
  }

  /// Returns `true` when the parsed item line totals sum to within ±0.02 of the
  /// parsed [ReceiptParseResult.subtotal]. A reported subtotal of 0 (not found)
  /// is treated as valid.
  bool validateTotal(ReceiptParseResult result) {
    if (result.subtotal == 0) return true;
    final double itemsSum = result.items.fold(
      0,
      (double sum, ParsedItem item) => sum + item.unitPrice * item.quantity,
    );
    return (itemsSum - result.subtotal).abs() <= _subtotalTolerance;
  }
}
