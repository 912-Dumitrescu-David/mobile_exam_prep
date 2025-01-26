// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TestEntity _$TestEntityFromJson(Map<String, dynamic> json) => TestEntity(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
    );

Map<String, dynamic> _$TestEntityToJson(TestEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };
