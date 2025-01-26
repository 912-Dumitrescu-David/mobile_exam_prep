import 'package:floor/floor.dart';
import 'package:json_annotation/json_annotation.dart';

part 'entity.g.dart';

@JsonSerializable()
class TestEntity extends Entity {
  @primaryKey
  final int id;
  final String name;

  TestEntity({required this.id, required this.name});

  factory TestEntity.fromJson(Map<String, dynamic> json) => _$TestEntityFromJson(json);
  Map<String, dynamic> toJson() => _$TestEntityToJson(this);

  @override
  String toString() {
    return '($id, $name)';
  }

  static Map<String, dynamic> toDatabaseAttributes(){
    return {'id' : ' INTEGER PRIMARY KEY AUTOINCREMENT', 'name' : ' TEXT'};
  }
}
