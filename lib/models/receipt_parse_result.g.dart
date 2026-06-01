// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt_parse_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ParsedItemImpl _$$ParsedItemImplFromJson(Map<String, dynamic> json) =>
    _$ParsedItemImpl(
      name: json['name'] as String,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1,
      unitPrice: (json['unit_price'] as num).toDouble(),
    );

Map<String, dynamic> _$$ParsedItemImplToJson(_$ParsedItemImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'quantity': instance.quantity,
      'unit_price': instance.unitPrice,
    };

_$ReceiptParseResultImpl _$$ReceiptParseResultImplFromJson(
  Map<String, dynamic> json,
) => _$ReceiptParseResultImpl(
  items: (json['items'] as List<dynamic>)
      .map((e) => ParsedItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
  tax: (json['tax'] as num?)?.toDouble() ?? 0,
  tip: (json['tip'] as num?)?.toDouble() ?? 0,
  total: (json['total'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$$ReceiptParseResultImplToJson(
  _$ReceiptParseResultImpl instance,
) => <String, dynamic>{
  'items': instance.items,
  'subtotal': instance.subtotal,
  'tax': instance.tax,
  'tip': instance.tip,
  'total': instance.total,
};
