// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'symbol_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SymbolInfo _$SymbolInfoFromJson(Map<String, dynamic> json) => SymbolInfo(
      (json['id'] as num).toInt(),
      json['symbolEn'] as String,
      json['symbolCn'] as String,
      (json['digits'] as num).toInt(),
      (json['stopsLevel'] as num).toInt(),
      (json['gtcPendings'] as num).toInt(),
      (json['contractSize'] as num).toDouble(),
      (json['profitMode'] as num).toInt(),
      json['groupType'] as String,
      (json['lever'] as num).toInt(),
      (json['maxLever'] as num).toInt(),
      (json['type'] as num).toInt(),
      (json['minVolume'] as num).toDouble(),
      (json['createdAt'] as num).toInt(),
      (json['updatedAt'] as num).toInt(),
      (json['status'] as num).toInt(),
      (json['isDel'] as num).toInt(),
      (json['accType'] as num).toInt(),
      (json['maxVolume'] as num).toDouble(),
      (json['commission'] as num).toDouble(),
      (json['interest'] as num).toDouble(),
      (json['priceTick'] as num).toDouble(),
    );

Map<String, dynamic> _$SymbolInfoToJson(SymbolInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'symbolEn': instance.symbolEn,
      'symbolCn': instance.symbolCn,
      'digits': instance.digits,
      'stopsLevel': instance.stopsLevel,
      'gtcPendings': instance.gtcPendings,
      'contractSize': instance.contractSize,
      'profitMode': instance.profitMode,
      'groupType': instance.groupType,
      'lever': instance.lever,
      'maxLever': instance.maxLever,
      'type': instance.type,
      'minVolume': instance.minVolume,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'status': instance.status,
      'isDel': instance.isDel,
      'accType': instance.accType,
      'maxVolume': instance.maxVolume,
      'commission': instance.commission,
      'interest': instance.interest,
      'priceTick': instance.priceTick,
    };
