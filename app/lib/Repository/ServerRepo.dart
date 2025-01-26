import 'dart:convert';

import 'package:app/Model/entity.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

const String url = "http://localhost:3000";

class ServerRepo {
  static final dio = Dio();
  var logger = Logger();

  ServerRepo();

  Future<List<TestEntity>> getAllEntities() async {
    logger.log(Level.info, "getAllEntities() called to server");
    final response = await dio.get("$url/entities");
    logger.log(Level.info, "getAllEntities() server response : $response");
    if(response.statusCode == 200){
      return (response.data as List).map((json) => TestEntity.fromJson(json)).toList();
    }else{
      logger.log(Level.error, "getAllEntities server error : ${response.statusMessage}");
      throw Exception(response.statusMessage);
    }
  }

  Future<TestEntity> addEntity(TestEntity newEntity) async{
    logger.log(Level.info, "addEntity() called");
    final response = await dio.post('$url/entities', data: newEntity.toJson());
    logger.log(Level.info, "addEntity() response: ${response}");
    if (response.statusCode == 201) {
      return TestEntity.fromJson(response.data);
    } else {
      logger.log(Level.error, "addEntity() error: ${response.statusMessage}");
      throw Exception(response.statusMessage);
    }
  }

  Future<void> deleteEntity(int id) async{
    logger.log(Level.info, '$url/entities/$id');
    final response = await dio.delete('$url/entities/$id');
    logger.log(Level.info, "$response");
  }

  Future<void> updateEntity(int id, TestEntity newEntity) async{
    final response = await dio.put('$url/entities/$id', data: newEntity.toJson());
  }
  
}