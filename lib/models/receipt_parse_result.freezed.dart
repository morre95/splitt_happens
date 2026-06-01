// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'receipt_parse_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ParsedItem _$ParsedItemFromJson(Map<String, dynamic> json) {
  return _ParsedItem.fromJson(json);
}

/// @nodoc
mixin _$ParsedItem {
  /// Item name, expanded to readable English by the model.
  String get name => throw _privateConstructorUsedError;

  /// Quantity purchased; the model defaults this to 1 when absent.
  double get quantity => throw _privateConstructorUsedError;

  /// Unit price as a plain number (no currency symbol).
  @JsonKey(name: 'unit_price')
  double get unitPrice => throw _privateConstructorUsedError;

  /// Serializes this ParsedItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ParsedItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ParsedItemCopyWith<ParsedItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ParsedItemCopyWith<$Res> {
  factory $ParsedItemCopyWith(
    ParsedItem value,
    $Res Function(ParsedItem) then,
  ) = _$ParsedItemCopyWithImpl<$Res, ParsedItem>;
  @useResult
  $Res call({
    String name,
    double quantity,
    @JsonKey(name: 'unit_price') double unitPrice,
  });
}

/// @nodoc
class _$ParsedItemCopyWithImpl<$Res, $Val extends ParsedItem>
    implements $ParsedItemCopyWith<$Res> {
  _$ParsedItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ParsedItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? quantity = null,
    Object? unitPrice = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            quantity: null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                      as double,
            unitPrice: null == unitPrice
                ? _value.unitPrice
                : unitPrice // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ParsedItemImplCopyWith<$Res>
    implements $ParsedItemCopyWith<$Res> {
  factory _$$ParsedItemImplCopyWith(
    _$ParsedItemImpl value,
    $Res Function(_$ParsedItemImpl) then,
  ) = __$$ParsedItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    double quantity,
    @JsonKey(name: 'unit_price') double unitPrice,
  });
}

/// @nodoc
class __$$ParsedItemImplCopyWithImpl<$Res>
    extends _$ParsedItemCopyWithImpl<$Res, _$ParsedItemImpl>
    implements _$$ParsedItemImplCopyWith<$Res> {
  __$$ParsedItemImplCopyWithImpl(
    _$ParsedItemImpl _value,
    $Res Function(_$ParsedItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ParsedItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? quantity = null,
    Object? unitPrice = null,
  }) {
    return _then(
      _$ParsedItemImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        quantity: null == quantity
            ? _value.quantity
            : quantity // ignore: cast_nullable_to_non_nullable
                  as double,
        unitPrice: null == unitPrice
            ? _value.unitPrice
            : unitPrice // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ParsedItemImpl implements _ParsedItem {
  const _$ParsedItemImpl({
    required this.name,
    this.quantity = 1,
    @JsonKey(name: 'unit_price') required this.unitPrice,
  });

  factory _$ParsedItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ParsedItemImplFromJson(json);

  /// Item name, expanded to readable English by the model.
  @override
  final String name;

  /// Quantity purchased; the model defaults this to 1 when absent.
  @override
  @JsonKey()
  final double quantity;

  /// Unit price as a plain number (no currency symbol).
  @override
  @JsonKey(name: 'unit_price')
  final double unitPrice;

  @override
  String toString() {
    return 'ParsedItem(name: $name, quantity: $quantity, unitPrice: $unitPrice)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ParsedItemImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, quantity, unitPrice);

  /// Create a copy of ParsedItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ParsedItemImplCopyWith<_$ParsedItemImpl> get copyWith =>
      __$$ParsedItemImplCopyWithImpl<_$ParsedItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ParsedItemImplToJson(this);
  }
}

abstract class _ParsedItem implements ParsedItem {
  const factory _ParsedItem({
    required final String name,
    final double quantity,
    @JsonKey(name: 'unit_price') required final double unitPrice,
  }) = _$ParsedItemImpl;

  factory _ParsedItem.fromJson(Map<String, dynamic> json) =
      _$ParsedItemImpl.fromJson;

  /// Item name, expanded to readable English by the model.
  @override
  String get name;

  /// Quantity purchased; the model defaults this to 1 when absent.
  @override
  double get quantity;

  /// Unit price as a plain number (no currency symbol).
  @override
  @JsonKey(name: 'unit_price')
  double get unitPrice;

  /// Create a copy of ParsedItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ParsedItemImplCopyWith<_$ParsedItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReceiptParseResult _$ReceiptParseResultFromJson(Map<String, dynamic> json) {
  return _ReceiptParseResult.fromJson(json);
}

/// @nodoc
mixin _$ReceiptParseResult {
  /// All purchased items extracted from the receipt.
  List<ParsedItem> get items => throw _privateConstructorUsedError;

  /// Reported subtotal, or 0 if not found.
  double get subtotal => throw _privateConstructorUsedError;

  /// Reported tax, or 0 if not found.
  double get tax => throw _privateConstructorUsedError;

  /// Reported tip, or 0 if not found.
  double get tip => throw _privateConstructorUsedError;

  /// Reported grand total, or 0 if not found.
  double get total => throw _privateConstructorUsedError;

  /// Serializes this ReceiptParseResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReceiptParseResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReceiptParseResultCopyWith<ReceiptParseResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReceiptParseResultCopyWith<$Res> {
  factory $ReceiptParseResultCopyWith(
    ReceiptParseResult value,
    $Res Function(ReceiptParseResult) then,
  ) = _$ReceiptParseResultCopyWithImpl<$Res, ReceiptParseResult>;
  @useResult
  $Res call({
    List<ParsedItem> items,
    double subtotal,
    double tax,
    double tip,
    double total,
  });
}

/// @nodoc
class _$ReceiptParseResultCopyWithImpl<$Res, $Val extends ReceiptParseResult>
    implements $ReceiptParseResultCopyWith<$Res> {
  _$ReceiptParseResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReceiptParseResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? subtotal = null,
    Object? tax = null,
    Object? tip = null,
    Object? total = null,
  }) {
    return _then(
      _value.copyWith(
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<ParsedItem>,
            subtotal: null == subtotal
                ? _value.subtotal
                : subtotal // ignore: cast_nullable_to_non_nullable
                      as double,
            tax: null == tax
                ? _value.tax
                : tax // ignore: cast_nullable_to_non_nullable
                      as double,
            tip: null == tip
                ? _value.tip
                : tip // ignore: cast_nullable_to_non_nullable
                      as double,
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReceiptParseResultImplCopyWith<$Res>
    implements $ReceiptParseResultCopyWith<$Res> {
  factory _$$ReceiptParseResultImplCopyWith(
    _$ReceiptParseResultImpl value,
    $Res Function(_$ReceiptParseResultImpl) then,
  ) = __$$ReceiptParseResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<ParsedItem> items,
    double subtotal,
    double tax,
    double tip,
    double total,
  });
}

/// @nodoc
class __$$ReceiptParseResultImplCopyWithImpl<$Res>
    extends _$ReceiptParseResultCopyWithImpl<$Res, _$ReceiptParseResultImpl>
    implements _$$ReceiptParseResultImplCopyWith<$Res> {
  __$$ReceiptParseResultImplCopyWithImpl(
    _$ReceiptParseResultImpl _value,
    $Res Function(_$ReceiptParseResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReceiptParseResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? subtotal = null,
    Object? tax = null,
    Object? tip = null,
    Object? total = null,
  }) {
    return _then(
      _$ReceiptParseResultImpl(
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<ParsedItem>,
        subtotal: null == subtotal
            ? _value.subtotal
            : subtotal // ignore: cast_nullable_to_non_nullable
                  as double,
        tax: null == tax
            ? _value.tax
            : tax // ignore: cast_nullable_to_non_nullable
                  as double,
        tip: null == tip
            ? _value.tip
            : tip // ignore: cast_nullable_to_non_nullable
                  as double,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReceiptParseResultImpl implements _ReceiptParseResult {
  const _$ReceiptParseResultImpl({
    required final List<ParsedItem> items,
    this.subtotal = 0,
    this.tax = 0,
    this.tip = 0,
    this.total = 0,
  }) : _items = items;

  factory _$ReceiptParseResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReceiptParseResultImplFromJson(json);

  /// All purchased items extracted from the receipt.
  final List<ParsedItem> _items;

  /// All purchased items extracted from the receipt.
  @override
  List<ParsedItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  /// Reported subtotal, or 0 if not found.
  @override
  @JsonKey()
  final double subtotal;

  /// Reported tax, or 0 if not found.
  @override
  @JsonKey()
  final double tax;

  /// Reported tip, or 0 if not found.
  @override
  @JsonKey()
  final double tip;

  /// Reported grand total, or 0 if not found.
  @override
  @JsonKey()
  final double total;

  @override
  String toString() {
    return 'ReceiptParseResult(items: $items, subtotal: $subtotal, tax: $tax, tip: $tip, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReceiptParseResultImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.subtotal, subtotal) ||
                other.subtotal == subtotal) &&
            (identical(other.tax, tax) || other.tax == tax) &&
            (identical(other.tip, tip) || other.tip == tip) &&
            (identical(other.total, total) || other.total == total));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_items),
    subtotal,
    tax,
    tip,
    total,
  );

  /// Create a copy of ReceiptParseResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReceiptParseResultImplCopyWith<_$ReceiptParseResultImpl> get copyWith =>
      __$$ReceiptParseResultImplCopyWithImpl<_$ReceiptParseResultImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ReceiptParseResultImplToJson(this);
  }
}

abstract class _ReceiptParseResult implements ReceiptParseResult {
  const factory _ReceiptParseResult({
    required final List<ParsedItem> items,
    final double subtotal,
    final double tax,
    final double tip,
    final double total,
  }) = _$ReceiptParseResultImpl;

  factory _ReceiptParseResult.fromJson(Map<String, dynamic> json) =
      _$ReceiptParseResultImpl.fromJson;

  /// All purchased items extracted from the receipt.
  @override
  List<ParsedItem> get items;

  /// Reported subtotal, or 0 if not found.
  @override
  double get subtotal;

  /// Reported tax, or 0 if not found.
  @override
  double get tax;

  /// Reported tip, or 0 if not found.
  @override
  double get tip;

  /// Reported grand total, or 0 if not found.
  @override
  double get total;

  /// Create a copy of ReceiptParseResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReceiptParseResultImplCopyWith<_$ReceiptParseResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
