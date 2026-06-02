// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ItemImpl _$$ItemImplFromJson(Map<String, dynamic> json) => _$ItemImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  quantity: (json['quantity'] as num?)?.toDouble() ?? 1,
  unitPrice: (json['unitPrice'] as num).toDouble(),
);

Map<String, dynamic> _$$ItemImplToJson(_$ItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
    };

_$PersonImpl _$$PersonImplFromJson(Map<String, dynamic> json) => _$PersonImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  avatarColor: const ColorConverter().fromJson(
    (json['avatarColor'] as num).toInt(),
  ),
);

Map<String, dynamic> _$$PersonImplToJson(_$PersonImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'avatarColor': const ColorConverter().toJson(instance.avatarColor),
    };

_$SplitImpl _$$SplitImplFromJson(Map<String, dynamic> json) => _$SplitImpl(
  personId: json['personId'] as String,
  itemId: json['itemId'] as String,
  portionNumerator: (json['portionNumerator'] as num).toInt(),
  portionDenominator: (json['portionDenominator'] as num).toInt(),
);

Map<String, dynamic> _$$SplitImplToJson(_$SplitImpl instance) =>
    <String, dynamic>{
      'personId': instance.personId,
      'itemId': instance.itemId,
      'portionNumerator': instance.portionNumerator,
      'portionDenominator': instance.portionDenominator,
    };

_$PaymentImpl _$$PaymentImplFromJson(Map<String, dynamic> json) =>
    _$PaymentImpl(
      personId: json['personId'] as String,
      amount: (json['amount'] as num).toDouble(),
    );

Map<String, dynamic> _$$PaymentImplToJson(_$PaymentImpl instance) =>
    <String, dynamic>{'personId': instance.personId, 'amount': instance.amount};

_$BillImpl _$$BillImplFromJson(Map<String, dynamic> json) => _$BillImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  date: DateTime.parse(json['date'] as String),
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => Item.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Item>[],
  people:
      (json['people'] as List<dynamic>?)
          ?.map((e) => Person.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Person>[],
  splits:
      (json['splits'] as List<dynamic>?)
          ?.map((e) => Split.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Split>[],
  payments:
      (json['payments'] as List<dynamic>?)
          ?.map((e) => Payment.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Payment>[],
  taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0,
  tipAmount: (json['tipAmount'] as num?)?.toDouble() ?? 0,
  currency: json['currency'] as String? ?? 'USD',
);

Map<String, dynamic> _$$BillImplToJson(_$BillImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'date': instance.date.toIso8601String(),
      'items': instance.items,
      'people': instance.people,
      'splits': instance.splits,
      'payments': instance.payments,
      'taxAmount': instance.taxAmount,
      'tipAmount': instance.tipAmount,
      'currency': instance.currency,
    };
