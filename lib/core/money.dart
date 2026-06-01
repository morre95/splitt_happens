/// Currency formatting helpers shared across screens.
library;

/// Common currency symbols keyed by ISO code; falls back to the code itself.
const Map<String, String> _symbols = <String, String>{
  'USD': r'$',
  'EUR': '€',
  'GBP': '£',
  'JPY': '¥',
  'SEK': 'kr',
};

/// Formats [amount] for display using the [currency] ISO code, e.g.
/// `formatMoney(12.5, 'USD')` → `"$12.50"`.
String formatMoney(double amount, String currency) {
  final String symbol = _symbols[currency] ?? '$currency ';
  return '$symbol${amount.toStringAsFixed(2)}';
}
