import 'package:floor/floor.dart';
import 'package:json_annotation/json_annotation.dart';

part 'entity.g.dart';

@JsonSerializable()
class TestEntity extends Entity {
  final int id;
  final String name;
  late String? filter;

  TestEntity({required this.id, required this.name, this.filter});

  factory TestEntity.fromJson(Map<String, dynamic> json) => _$TestEntityFromJson(json);
  Map<String, dynamic> toJson() => _$TestEntityToJson(this);

  @override
  String toString() {
    return '($id, $name, $filter)';
  }

  static Map<String, dynamic> toDatabaseAttributes(){
    return {'id' : ' INTEGER PRIMARY KEY AUTOINCREMENT', 'name' : ' TEXT', 'filter' : ' TEXT'};
  }
}
