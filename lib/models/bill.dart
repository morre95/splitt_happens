import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'bill.freezed.dart';
part 'bill.g.dart';

/// Serializes a [Color] to/from its 32-bit ARGB integer representation so it
/// can be persisted as JSON and in the database.
class ColorConverter implements JsonConverter<Color, int> {
  /// Creates a const [ColorConverter].
  const ColorConverter();

  @override
  Color fromJson(int json) => Color(json);

  @override
  int toJson(Color color) => color.toARGB32();
}

/// A single line on a receipt — for example "2 × Chicken Sandwich @ 8.50".
@freezed
class Item with _$Item {
  /// Creates an [Item].
  const factory Item({
    /// Unique identifier (UUID v4).
    required String id,

    /// Display name of the item.
    required String name,

    /// How many units were purchased. Defaults to 1.
    @Default(1) double quantity,

    /// Price of a single unit, with no currency symbol.
    required double unitPrice,
  }) = _Item;

  const Item._();

  /// Deserializes an [Item] from JSON.
  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);

  /// Total cost of this line: [unitPrice] × [quantity].
  double get lineTotal => unitPrice * quantity;
}

/// A participant who shares the bill.
@freezed
class Person with _$Person {
  /// Creates a [Person].
  const factory Person({
    /// Unique identifier (UUID v4).
    required String id,

    /// Display name.
    required String name,

    /// Colour used for this person's avatar throughout the UI.
    @ColorConverter() required Color avatarColor,
  }) = _Person;

  /// Deserializes a [Person] from JSON.
  factory Person.fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);
}

/// Describes how much of a given [Item] a given [Person] is responsible for,
/// expressed as an exact fraction to avoid floating-point drift.
@freezed
class Split with _$Split {
  /// Creates a [Split].
  const factory Split({
    /// The owning person's id.
    required String personId,

    /// The item being split.
    required String itemId,

    /// Numerator of the portion this person owns.
    required int portionNumerator,

    /// Denominator of the portion this person owns.
    required int portionDenominator,
  }) = _Split;

  /// Deserializes a [Split] from JSON.
  factory Split.fromJson(Map<String, dynamic> json) => _$SplitFromJson(json);
}

/// How much a given [Person] actually paid towards the bill. Used to settle up
/// after the fact: a person's net balance is what they paid minus what they
/// owe.
@freezed
class Payment with _$Payment {
  /// Creates a [Payment].
  const factory Payment({
    /// The paying person's id.
    required String personId,

    /// The amount this person paid, in currency units.
    required double amount,
  }) = _Payment;

  /// Deserializes a [Payment] from JSON.
  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);
}

/// Top-level container for a single receipt-splitting session.
@freezed
class Bill with _$Bill {
  /// Creates a [Bill].
  const factory Bill({
    /// Unique identifier (UUID v4).
    required String id,

    /// User-facing name, e.g. the restaurant or occasion.
    required String name,

    /// When the bill was created.
    required DateTime date,

    /// All parsed/edited line items.
    @Default(<Item>[]) List<Item> items,

    /// Everyone splitting this bill.
    @Default(<Person>[]) List<Person> people,

    /// Item-to-person ownership fractions.
    @Default(<Split>[]) List<Split> splits,

    /// How much each person actually paid towards the bill.
    @Default(<Payment>[]) List<Payment> payments,

    /// Total tax charged on the bill.
    @Default(0) double taxAmount,

    /// Total tip added to the bill.
    @Default(0) double tipAmount,

    /// ISO currency code, e.g. "USD".
    @Default('USD') String currency,
  }) = _Bill;

  const Bill._();

  /// Deserializes a [Bill] from JSON.
  factory Bill.fromJson(Map<String, dynamic> json) => _$BillFromJson(json);

  /// Sum of all item line totals (excluding tax and tip).
  double get subtotal =>
      items.fold(0, (double sum, Item item) => sum + item.lineTotal);

  /// Grand total including tax and tip.
  double get total => subtotal + taxAmount + tipAmount;

  /// Sum of all amounts people have paid towards the bill.
  double get totalPaid =>
      payments.fold(0, (double sum, Payment p) => sum + p.amount);
}
