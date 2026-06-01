import 'package:freezed_annotation/freezed_annotation.dart';

part 'receipt_parse_result.freezed.dart';
part 'receipt_parse_result.g.dart';

/// A single item as returned by the LLM receipt parser, before it is converted
/// into a domain [Item](../models/bill.dart) with a generated id.
@freezed
class ParsedItem with _$ParsedItem {
  /// Creates a [ParsedItem].
  const factory ParsedItem({
    /// Item name, expanded to readable English by the model.
    required String name,

    /// Quantity purchased; the model defaults this to 1 when absent.
    @Default(1) double quantity,

    /// Unit price as a plain number (no currency symbol).
    @JsonKey(name: 'unit_price') required double unitPrice,
  }) = _ParsedItem;

  /// Deserializes a [ParsedItem] from JSON.
  factory ParsedItem.fromJson(Map<String, dynamic> json) =>
      _$ParsedItemFromJson(json);
}

/// The structured result of parsing raw OCR text through the LLM.
///
/// Mirrors the exact JSON schema requested in the system prompt.
@freezed
class ReceiptParseResult with _$ReceiptParseResult {
  /// Creates a [ReceiptParseResult].
  const factory ReceiptParseResult({
    /// All purchased items extracted from the receipt.
    required List<ParsedItem> items,

    /// Reported subtotal, or 0 if not found.
    @Default(0) double subtotal,

    /// Reported tax, or 0 if not found.
    @Default(0) double tax,

    /// Reported tip, or 0 if not found.
    @Default(0) double tip,

    /// Reported grand total, or 0 if not found.
    @Default(0) double total,
  }) = _ReceiptParseResult;

  /// Deserializes a [ReceiptParseResult] from JSON.
  factory ReceiptParseResult.fromJson(Map<String, dynamic> json) =>
      _$ReceiptParseResultFromJson(json);
}
