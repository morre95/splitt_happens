// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bill.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Item _$ItemFromJson(Map<String, dynamic> json) {
  return _Item.fromJson(json);
}

/// @nodoc
mixin _$Item {
  /// Unique identifier (UUID v4).
  String get id => throw _privateConstructorUsedError;

  /// Display name of the item.
  String get name => throw _privateConstructorUsedError;

  /// How many units were purchased. Defaults to 1.
  double get quantity => throw _privateConstructorUsedError;

  /// Price of a single unit, with no currency symbol.
  double get unitPrice => throw _privateConstructorUsedError;

  /// Serializes this Item to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Item
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ItemCopyWith<Item> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ItemCopyWith<$Res> {
  factory $ItemCopyWith(Item value, $Res Function(Item) then) =
      _$ItemCopyWithImpl<$Res, Item>;
  @useResult
  $Res call({String id, String name, double quantity, double unitPrice});
}

/// @nodoc
class _$ItemCopyWithImpl<$Res, $Val extends Item>
    implements $ItemCopyWith<$Res> {
  _$ItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Item
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? quantity = null,
    Object? unitPrice = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
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
abstract class _$$ItemImplCopyWith<$Res> implements $ItemCopyWith<$Res> {
  factory _$$ItemImplCopyWith(
    _$ItemImpl value,
    $Res Function(_$ItemImpl) then,
  ) = __$$ItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, double quantity, double unitPrice});
}

/// @nodoc
class __$$ItemImplCopyWithImpl<$Res>
    extends _$ItemCopyWithImpl<$Res, _$ItemImpl>
    implements _$$ItemImplCopyWith<$Res> {
  __$$ItemImplCopyWithImpl(_$ItemImpl _value, $Res Function(_$ItemImpl) _then)
    : super(_value, _then);

  /// Create a copy of Item
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? quantity = null,
    Object? unitPrice = null,
  }) {
    return _then(
      _$ItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
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
class _$ItemImpl extends _Item {
  const _$ItemImpl({
    required this.id,
    required this.name,
    this.quantity = 1,
    required this.unitPrice,
  }) : super._();

  factory _$ItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ItemImplFromJson(json);

  /// Unique identifier (UUID v4).
  @override
  final String id;

  /// Display name of the item.
  @override
  final String name;

  /// How many units were purchased. Defaults to 1.
  @override
  @JsonKey()
  final double quantity;

  /// Price of a single unit, with no currency symbol.
  @override
  final double unitPrice;

  @override
  String toString() {
    return 'Item(id: $id, name: $name, quantity: $quantity, unitPrice: $unitPrice)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, quantity, unitPrice);

  /// Create a copy of Item
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ItemImplCopyWith<_$ItemImpl> get copyWith =>
      __$$ItemImplCopyWithImpl<_$ItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ItemImplToJson(this);
  }
}

abstract class _Item extends Item {
  const factory _Item({
    required final String id,
    required final String name,
    final double quantity,
    required final double unitPrice,
  }) = _$ItemImpl;
  const _Item._() : super._();

  factory _Item.fromJson(Map<String, dynamic> json) = _$ItemImpl.fromJson;

  /// Unique identifier (UUID v4).
  @override
  String get id;

  /// Display name of the item.
  @override
  String get name;

  /// How many units were purchased. Defaults to 1.
  @override
  double get quantity;

  /// Price of a single unit, with no currency symbol.
  @override
  double get unitPrice;

  /// Create a copy of Item
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ItemImplCopyWith<_$ItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Person _$PersonFromJson(Map<String, dynamic> json) {
  return _Person.fromJson(json);
}

/// @nodoc
mixin _$Person {
  /// Unique identifier (UUID v4).
  String get id => throw _privateConstructorUsedError;

  /// Display name.
  String get name => throw _privateConstructorUsedError;

  /// Colour used for this person's avatar throughout the UI.
  @ColorConverter()
  Color get avatarColor => throw _privateConstructorUsedError;

  /// Serializes this Person to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Person
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PersonCopyWith<Person> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PersonCopyWith<$Res> {
  factory $PersonCopyWith(Person value, $Res Function(Person) then) =
      _$PersonCopyWithImpl<$Res, Person>;
  @useResult
  $Res call({String id, String name, @ColorConverter() Color avatarColor});
}

/// @nodoc
class _$PersonCopyWithImpl<$Res, $Val extends Person>
    implements $PersonCopyWith<$Res> {
  _$PersonCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Person
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? avatarColor = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            avatarColor: null == avatarColor
                ? _value.avatarColor
                : avatarColor // ignore: cast_nullable_to_non_nullable
                      as Color,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PersonImplCopyWith<$Res> implements $PersonCopyWith<$Res> {
  factory _$$PersonImplCopyWith(
    _$PersonImpl value,
    $Res Function(_$PersonImpl) then,
  ) = __$$PersonImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, @ColorConverter() Color avatarColor});
}

/// @nodoc
class __$$PersonImplCopyWithImpl<$Res>
    extends _$PersonCopyWithImpl<$Res, _$PersonImpl>
    implements _$$PersonImplCopyWith<$Res> {
  __$$PersonImplCopyWithImpl(
    _$PersonImpl _value,
    $Res Function(_$PersonImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Person
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? avatarColor = null,
  }) {
    return _then(
      _$PersonImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        avatarColor: null == avatarColor
            ? _value.avatarColor
            : avatarColor // ignore: cast_nullable_to_non_nullable
                  as Color,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PersonImpl implements _Person {
  const _$PersonImpl({
    required this.id,
    required this.name,
    @ColorConverter() required this.avatarColor,
  });

  factory _$PersonImpl.fromJson(Map<String, dynamic> json) =>
      _$$PersonImplFromJson(json);

  /// Unique identifier (UUID v4).
  @override
  final String id;

  /// Display name.
  @override
  final String name;

  /// Colour used for this person's avatar throughout the UI.
  @override
  @ColorConverter()
  final Color avatarColor;

  @override
  String toString() {
    return 'Person(id: $id, name: $name, avatarColor: $avatarColor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PersonImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.avatarColor, avatarColor) ||
                other.avatarColor == avatarColor));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, avatarColor);

  /// Create a copy of Person
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PersonImplCopyWith<_$PersonImpl> get copyWith =>
      __$$PersonImplCopyWithImpl<_$PersonImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PersonImplToJson(this);
  }
}

abstract class _Person implements Person {
  const factory _Person({
    required final String id,
    required final String name,
    @ColorConverter() required final Color avatarColor,
  }) = _$PersonImpl;

  factory _Person.fromJson(Map<String, dynamic> json) = _$PersonImpl.fromJson;

  /// Unique identifier (UUID v4).
  @override
  String get id;

  /// Display name.
  @override
  String get name;

  /// Colour used for this person's avatar throughout the UI.
  @override
  @ColorConverter()
  Color get avatarColor;

  /// Create a copy of Person
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PersonImplCopyWith<_$PersonImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Split _$SplitFromJson(Map<String, dynamic> json) {
  return _Split.fromJson(json);
}

/// @nodoc
mixin _$Split {
  /// The owning person's id.
  String get personId => throw _privateConstructorUsedError;

  /// The item being split.
  String get itemId => throw _privateConstructorUsedError;

  /// Numerator of the portion this person owns.
  int get portionNumerator => throw _privateConstructorUsedError;

  /// Denominator of the portion this person owns.
  int get portionDenominator => throw _privateConstructorUsedError;

  /// Serializes this Split to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Split
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SplitCopyWith<Split> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SplitCopyWith<$Res> {
  factory $SplitCopyWith(Split value, $Res Function(Split) then) =
      _$SplitCopyWithImpl<$Res, Split>;
  @useResult
  $Res call({
    String personId,
    String itemId,
    int portionNumerator,
    int portionDenominator,
  });
}

/// @nodoc
class _$SplitCopyWithImpl<$Res, $Val extends Split>
    implements $SplitCopyWith<$Res> {
  _$SplitCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Split
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? personId = null,
    Object? itemId = null,
    Object? portionNumerator = null,
    Object? portionDenominator = null,
  }) {
    return _then(
      _value.copyWith(
            personId: null == personId
                ? _value.personId
                : personId // ignore: cast_nullable_to_non_nullable
                      as String,
            itemId: null == itemId
                ? _value.itemId
                : itemId // ignore: cast_nullable_to_non_nullable
                      as String,
            portionNumerator: null == portionNumerator
                ? _value.portionNumerator
                : portionNumerator // ignore: cast_nullable_to_non_nullable
                      as int,
            portionDenominator: null == portionDenominator
                ? _value.portionDenominator
                : portionDenominator // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SplitImplCopyWith<$Res> implements $SplitCopyWith<$Res> {
  factory _$$SplitImplCopyWith(
    _$SplitImpl value,
    $Res Function(_$SplitImpl) then,
  ) = __$$SplitImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String personId,
    String itemId,
    int portionNumerator,
    int portionDenominator,
  });
}

/// @nodoc
class __$$SplitImplCopyWithImpl<$Res>
    extends _$SplitCopyWithImpl<$Res, _$SplitImpl>
    implements _$$SplitImplCopyWith<$Res> {
  __$$SplitImplCopyWithImpl(
    _$SplitImpl _value,
    $Res Function(_$SplitImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Split
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? personId = null,
    Object? itemId = null,
    Object? portionNumerator = null,
    Object? portionDenominator = null,
  }) {
    return _then(
      _$SplitImpl(
        personId: null == personId
            ? _value.personId
            : personId // ignore: cast_nullable_to_non_nullable
                  as String,
        itemId: null == itemId
            ? _value.itemId
            : itemId // ignore: cast_nullable_to_non_nullable
                  as String,
        portionNumerator: null == portionNumerator
            ? _value.portionNumerator
            : portionNumerator // ignore: cast_nullable_to_non_nullable
                  as int,
        portionDenominator: null == portionDenominator
            ? _value.portionDenominator
            : portionDenominator // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SplitImpl implements _Split {
  const _$SplitImpl({
    required this.personId,
    required this.itemId,
    required this.portionNumerator,
    required this.portionDenominator,
  });

  factory _$SplitImpl.fromJson(Map<String, dynamic> json) =>
      _$$SplitImplFromJson(json);

  /// The owning person's id.
  @override
  final String personId;

  /// The item being split.
  @override
  final String itemId;

  /// Numerator of the portion this person owns.
  @override
  final int portionNumerator;

  /// Denominator of the portion this person owns.
  @override
  final int portionDenominator;

  @override
  String toString() {
    return 'Split(personId: $personId, itemId: $itemId, portionNumerator: $portionNumerator, portionDenominator: $portionDenominator)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SplitImpl &&
            (identical(other.personId, personId) ||
                other.personId == personId) &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.portionNumerator, portionNumerator) ||
                other.portionNumerator == portionNumerator) &&
            (identical(other.portionDenominator, portionDenominator) ||
                other.portionDenominator == portionDenominator));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    personId,
    itemId,
    portionNumerator,
    portionDenominator,
  );

  /// Create a copy of Split
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SplitImplCopyWith<_$SplitImpl> get copyWith =>
      __$$SplitImplCopyWithImpl<_$SplitImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SplitImplToJson(this);
  }
}

abstract class _Split implements Split {
  const factory _Split({
    required final String personId,
    required final String itemId,
    required final int portionNumerator,
    required final int portionDenominator,
  }) = _$SplitImpl;

  factory _Split.fromJson(Map<String, dynamic> json) = _$SplitImpl.fromJson;

  /// The owning person's id.
  @override
  String get personId;

  /// The item being split.
  @override
  String get itemId;

  /// Numerator of the portion this person owns.
  @override
  int get portionNumerator;

  /// Denominator of the portion this person owns.
  @override
  int get portionDenominator;

  /// Create a copy of Split
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SplitImplCopyWith<_$SplitImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Payment _$PaymentFromJson(Map<String, dynamic> json) {
  return _Payment.fromJson(json);
}

/// @nodoc
mixin _$Payment {
  /// The paying person's id.
  String get personId => throw _privateConstructorUsedError;

  /// The amount this person paid, in currency units.
  double get amount => throw _privateConstructorUsedError;

  /// Serializes this Payment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Payment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaymentCopyWith<Payment> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentCopyWith<$Res> {
  factory $PaymentCopyWith(Payment value, $Res Function(Payment) then) =
      _$PaymentCopyWithImpl<$Res, Payment>;
  @useResult
  $Res call({String personId, double amount});
}

/// @nodoc
class _$PaymentCopyWithImpl<$Res, $Val extends Payment>
    implements $PaymentCopyWith<$Res> {
  _$PaymentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Payment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? personId = null, Object? amount = null}) {
    return _then(
      _value.copyWith(
            personId: null == personId
                ? _value.personId
                : personId // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PaymentImplCopyWith<$Res> implements $PaymentCopyWith<$Res> {
  factory _$$PaymentImplCopyWith(
    _$PaymentImpl value,
    $Res Function(_$PaymentImpl) then,
  ) = __$$PaymentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String personId, double amount});
}

/// @nodoc
class __$$PaymentImplCopyWithImpl<$Res>
    extends _$PaymentCopyWithImpl<$Res, _$PaymentImpl>
    implements _$$PaymentImplCopyWith<$Res> {
  __$$PaymentImplCopyWithImpl(
    _$PaymentImpl _value,
    $Res Function(_$PaymentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Payment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? personId = null, Object? amount = null}) {
    return _then(
      _$PaymentImpl(
        personId: null == personId
            ? _value.personId
            : personId // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PaymentImpl implements _Payment {
  const _$PaymentImpl({required this.personId, required this.amount});

  factory _$PaymentImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaymentImplFromJson(json);

  /// The paying person's id.
  @override
  final String personId;

  /// The amount this person paid, in currency units.
  @override
  final double amount;

  @override
  String toString() {
    return 'Payment(personId: $personId, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentImpl &&
            (identical(other.personId, personId) ||
                other.personId == personId) &&
            (identical(other.amount, amount) || other.amount == amount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, personId, amount);

  /// Create a copy of Payment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentImplCopyWith<_$PaymentImpl> get copyWith =>
      __$$PaymentImplCopyWithImpl<_$PaymentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PaymentImplToJson(this);
  }
}

abstract class _Payment implements Payment {
  const factory _Payment({
    required final String personId,
    required final double amount,
  }) = _$PaymentImpl;

  factory _Payment.fromJson(Map<String, dynamic> json) = _$PaymentImpl.fromJson;

  /// The paying person's id.
  @override
  String get personId;

  /// The amount this person paid, in currency units.
  @override
  double get amount;

  /// Create a copy of Payment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentImplCopyWith<_$PaymentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Bill _$BillFromJson(Map<String, dynamic> json) {
  return _Bill.fromJson(json);
}

/// @nodoc
mixin _$Bill {
  /// Unique identifier (UUID v4).
  String get id => throw _privateConstructorUsedError;

  /// User-facing name, e.g. the restaurant or occasion.
  String get name => throw _privateConstructorUsedError;

  /// When the bill was created.
  DateTime get date => throw _privateConstructorUsedError;

  /// All parsed/edited line items.
  List<Item> get items => throw _privateConstructorUsedError;

  /// Everyone splitting this bill.
  List<Person> get people => throw _privateConstructorUsedError;

  /// Item-to-person ownership fractions.
  List<Split> get splits => throw _privateConstructorUsedError;

  /// How much each person actually paid towards the bill.
  List<Payment> get payments => throw _privateConstructorUsedError;

  /// Total tax charged on the bill.
  double get taxAmount => throw _privateConstructorUsedError;

  /// Total tip added to the bill.
  double get tipAmount => throw _privateConstructorUsedError;

  /// ISO currency code, e.g. "USD".
  String get currency => throw _privateConstructorUsedError;

  /// Serializes this Bill to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Bill
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BillCopyWith<Bill> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BillCopyWith<$Res> {
  factory $BillCopyWith(Bill value, $Res Function(Bill) then) =
      _$BillCopyWithImpl<$Res, Bill>;
  @useResult
  $Res call({
    String id,
    String name,
    DateTime date,
    List<Item> items,
    List<Person> people,
    List<Split> splits,
    List<Payment> payments,
    double taxAmount,
    double tipAmount,
    String currency,
  });
}

/// @nodoc
class _$BillCopyWithImpl<$Res, $Val extends Bill>
    implements $BillCopyWith<$Res> {
  _$BillCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Bill
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? date = null,
    Object? items = null,
    Object? people = null,
    Object? splits = null,
    Object? payments = null,
    Object? taxAmount = null,
    Object? tipAmount = null,
    Object? currency = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<Item>,
            people: null == people
                ? _value.people
                : people // ignore: cast_nullable_to_non_nullable
                      as List<Person>,
            splits: null == splits
                ? _value.splits
                : splits // ignore: cast_nullable_to_non_nullable
                      as List<Split>,
            payments: null == payments
                ? _value.payments
                : payments // ignore: cast_nullable_to_non_nullable
                      as List<Payment>,
            taxAmount: null == taxAmount
                ? _value.taxAmount
                : taxAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            tipAmount: null == tipAmount
                ? _value.tipAmount
                : tipAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BillImplCopyWith<$Res> implements $BillCopyWith<$Res> {
  factory _$$BillImplCopyWith(
    _$BillImpl value,
    $Res Function(_$BillImpl) then,
  ) = __$$BillImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    DateTime date,
    List<Item> items,
    List<Person> people,
    List<Split> splits,
    List<Payment> payments,
    double taxAmount,
    double tipAmount,
    String currency,
  });
}

/// @nodoc
class __$$BillImplCopyWithImpl<$Res>
    extends _$BillCopyWithImpl<$Res, _$BillImpl>
    implements _$$BillImplCopyWith<$Res> {
  __$$BillImplCopyWithImpl(_$BillImpl _value, $Res Function(_$BillImpl) _then)
    : super(_value, _then);

  /// Create a copy of Bill
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? date = null,
    Object? items = null,
    Object? people = null,
    Object? splits = null,
    Object? payments = null,
    Object? taxAmount = null,
    Object? tipAmount = null,
    Object? currency = null,
  }) {
    return _then(
      _$BillImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<Item>,
        people: null == people
            ? _value._people
            : people // ignore: cast_nullable_to_non_nullable
                  as List<Person>,
        splits: null == splits
            ? _value._splits
            : splits // ignore: cast_nullable_to_non_nullable
                  as List<Split>,
        payments: null == payments
            ? _value._payments
            : payments // ignore: cast_nullable_to_non_nullable
                  as List<Payment>,
        taxAmount: null == taxAmount
            ? _value.taxAmount
            : taxAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        tipAmount: null == tipAmount
            ? _value.tipAmount
            : tipAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BillImpl extends _Bill {
  const _$BillImpl({
    required this.id,
    required this.name,
    required this.date,
    final List<Item> items = const <Item>[],
    final List<Person> people = const <Person>[],
    final List<Split> splits = const <Split>[],
    final List<Payment> payments = const <Payment>[],
    this.taxAmount = 0,
    this.tipAmount = 0,
    this.currency = 'USD',
  }) : _items = items,
       _people = people,
       _splits = splits,
       _payments = payments,
       super._();

  factory _$BillImpl.fromJson(Map<String, dynamic> json) =>
      _$$BillImplFromJson(json);

  /// Unique identifier (UUID v4).
  @override
  final String id;

  /// User-facing name, e.g. the restaurant or occasion.
  @override
  final String name;

  /// When the bill was created.
  @override
  final DateTime date;

  /// All parsed/edited line items.
  final List<Item> _items;

  /// All parsed/edited line items.
  @override
  @JsonKey()
  List<Item> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  /// Everyone splitting this bill.
  final List<Person> _people;

  /// Everyone splitting this bill.
  @override
  @JsonKey()
  List<Person> get people {
    if (_people is EqualUnmodifiableListView) return _people;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_people);
  }

  /// Item-to-person ownership fractions.
  final List<Split> _splits;

  /// Item-to-person ownership fractions.
  @override
  @JsonKey()
  List<Split> get splits {
    if (_splits is EqualUnmodifiableListView) return _splits;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_splits);
  }

  /// How much each person actually paid towards the bill.
  final List<Payment> _payments;

  /// How much each person actually paid towards the bill.
  @override
  @JsonKey()
  List<Payment> get payments {
    if (_payments is EqualUnmodifiableListView) return _payments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_payments);
  }

  /// Total tax charged on the bill.
  @override
  @JsonKey()
  final double taxAmount;

  /// Total tip added to the bill.
  @override
  @JsonKey()
  final double tipAmount;

  /// ISO currency code, e.g. "USD".
  @override
  @JsonKey()
  final String currency;

  @override
  String toString() {
    return 'Bill(id: $id, name: $name, date: $date, items: $items, people: $people, splits: $splits, payments: $payments, taxAmount: $taxAmount, tipAmount: $tipAmount, currency: $currency)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BillImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.date, date) || other.date == date) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            const DeepCollectionEquality().equals(other._people, _people) &&
            const DeepCollectionEquality().equals(other._splits, _splits) &&
            const DeepCollectionEquality().equals(other._payments, _payments) &&
            (identical(other.taxAmount, taxAmount) ||
                other.taxAmount == taxAmount) &&
            (identical(other.tipAmount, tipAmount) ||
                other.tipAmount == tipAmount) &&
            (identical(other.currency, currency) ||
                other.currency == currency));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    date,
    const DeepCollectionEquality().hash(_items),
    const DeepCollectionEquality().hash(_people),
    const DeepCollectionEquality().hash(_splits),
    const DeepCollectionEquality().hash(_payments),
    taxAmount,
    tipAmount,
    currency,
  );

  /// Create a copy of Bill
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BillImplCopyWith<_$BillImpl> get copyWith =>
      __$$BillImplCopyWithImpl<_$BillImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BillImplToJson(this);
  }
}

abstract class _Bill extends Bill {
  const factory _Bill({
    required final String id,
    required final String name,
    required final DateTime date,
    final List<Item> items,
    final List<Person> people,
    final List<Split> splits,
    final List<Payment> payments,
    final double taxAmount,
    final double tipAmount,
    final String currency,
  }) = _$BillImpl;
  const _Bill._() : super._();

  factory _Bill.fromJson(Map<String, dynamic> json) = _$BillImpl.fromJson;

  /// Unique identifier (UUID v4).
  @override
  String get id;

  /// User-facing name, e.g. the restaurant or occasion.
  @override
  String get name;

  /// When the bill was created.
  @override
  DateTime get date;

  /// All parsed/edited line items.
  @override
  List<Item> get items;

  /// Everyone splitting this bill.
  @override
  List<Person> get people;

  /// Item-to-person ownership fractions.
  @override
  List<Split> get splits;

  /// How much each person actually paid towards the bill.
  @override
  List<Payment> get payments;

  /// Total tax charged on the bill.
  @override
  double get taxAmount;

  /// Total tip added to the bill.
  @override
  double get tipAmount;

  /// ISO currency code, e.g. "USD".
  @override
  String get currency;

  /// Create a copy of Bill
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BillImplCopyWith<_$BillImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
