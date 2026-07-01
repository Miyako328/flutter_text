// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
      json['e'] as String,
      json['c'] as String,
      json['a'] as String,
      json['b'] as String,
      json['C'] as String,
      json['E'] as String,
      json['f'] as String,
      json['h'] as String,
      json['q'] as String,
      json['m'] as String,
      json['P'] as String,
      json['p'] as num,
      json['s'] as String,
      json['F'] as String,
      json['u'] as String,
      json['w'] as String,
      json['sC'] as String,
      json['sc'] as String,
      json['Pa'] as String,
      json['t'] as num,
    );

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
      'e': instance.type,
      'c': instance.code,
      'f': instance.futureCode,
      'b': instance.business,
      'h': instance.hedgeSchemeCode,
      'p': instance.price,
      'a': instance.account,
      'P': instance.partner,
      'Pa': instance.partnerAlias,
      's': instance.side,
      'q': instance.lots,
      'E': instance.exchangeCode,
      'm': instance.material,
      'C': instance.productCode,
      'F': instance.finishLots,
      'w': instance.unLots,
      'u': instance.ingLots,
      'sc': instance.codeName,
      'sC': instance.contractCode,
      't': instance.time,
    };
