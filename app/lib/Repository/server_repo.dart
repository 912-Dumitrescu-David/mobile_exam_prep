import 'package:app/Model/entity.dart';
import 'package:app/Model/entityfilter.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

const String url = "http://192.168.1.14:3000";

class ServerRepo {
  static final dio = Dio();
  var logger = Logger();

  ServerRepo();

  Future<List<TestEntity>> getAllEntities() async {
    logger.log(Level.info, "getAllEntities() called to server");
    final response = await dio.get("$url/entities");
    logger.log(Level.info, "getAllEntities() server response : $response");
    if (response.statusCode == 200) {
      return (response.data as List)
          .map((json) => TestEntity.fromJson(json))
          .toList();
    } else {
      logger.log(Level.error,
          "getAllEntities server error : ${response.statusMessage}");
      throw Exception(response.statusMessage);
    }
  }

  Future<TestEntity> addEntity(TestEntity newEntity) async {
    logger.log(Level.info, "addEntity() called");
    try {
      final response =
          await dio.post('$url/entities', data: newEntity.toJson());
      logger.log(Level.info, "addEntity() response: $response");
      return TestEntity.fromJson(response.data);
    } catch (e) {
      logger.log(Level.error, "addEntity() error: $e");
    }
    return TestEntity(id: 0, name: "");
  }

  Future<bool> deleteEntity(int id) async {
    logger.log(Level.info, "deleteEntity() called");
    try {
      final response = await dio.delete('$url/entities/$id');
      logger.log(Level.info, "deleteEntity() response: $response");
      return true;
    } catch (e) {
      logger.log(Level.error, "deleteEntity() error: $e");
      return false;
    }
  }

  Future<bool> updateEntity(int id, TestEntity newEntity) async {
    logger.log(Level.info, "updateEntity() called");
    try {
      final response =
          await dio.put('$url/entities/$id', data: newEntity.toJson());
      logger.log(Level.info, "updateEntity() response: $response");
      return true;
    } catch (e) {
      logger.log(Level.error, "updateEntity() error: $e");
      return false;
    }
  }

    Future<TestEntity?> getById(int id) async {
    logger.log(Level.info, "getById() called with id: $id");
    try {
      final response = await dio.get('$url/entities/$id');
      logger.log(Level.info, "getById() response: $response");
      if (response.statusCode == 200) {
        return TestEntity.fromJson(response.data);
      } else {
        logger.log(Level.error,
            "getById server error: ${response.statusMessage}");
        throw Exception(response.statusMessage);
      }
    } catch (e) {
      logger.log(Level.error, "getById() error: $e");
      return null;
    }
  }

  Future<List<String?>> getAllFilters() async{
    logger.log(Level.info,"called getAllFilters on server");
    try{
      final response= await dio.get('$url/filters');
      logger.log(Level.info, "getALlFilters() response: $response");
      if( response.statusCode == 200){
        final List<dynamic> data = response.data;
        return data.map((item) => item.toString()).toList();
      }else {
        logger.log(Level.error,
            "getAllFilters server error: ${response.statusMessage}");
        throw Exception(response.statusMessage);
      }
    } catch(e){
      logger.log(Level.error,"getAllFilters() error: ${e}");
      return [];
    }

  }

  Future<List<TestEntity>> getEntityFilter(String filter) async {
    logger.log(Level.info, "getEntityFilter() called to server with filter: $filter");
    final response = await dio.get("$url/entities/$filter");
    logger.log(Level.info, "getEntityFilter() server response : $response");
    if (response.statusCode == 200) {
      return (response.data as List)
          .map((json) => TestEntity.fromJson(json))
          .toList();
    } else {
      logger.log(Level.error,
          "getAllEntities server error : ${response.statusMessage}");
      throw Exception(response.statusMessage);
    }
  }


}
