import 'package:app/Model/entity.dart';
import 'package:app/Repository/AbstractRepo.dart';
import 'package:app/Repository/ServerRepo.dart';
import 'package:logger/logger.dart';

class Controller {
  final Abstractrepo localRepo;
  final ServerRepo serverRepo;
  final bool isOnline;
  Controller({required this.localRepo, required this.serverRepo, required this.isOnline });

  static Logger logger = Logger();

  Future<List<TestEntity>> getAllEntities() async {
    List<TestEntity> entities = [];
    logger.log(Level.info, "Called getAllEntities in Service");
    if(isOnline){
      entities = await serverRepo.getAllEntities();
      logger.log(Level.info, "getAllEntities called from server result: $entities");
    }else{
      entities = await localRepo.getAllEntities();
      logger.log(Level.info, "getAllEntities called from local result: $entities");
    }
    return entities;
  }

  Future<TestEntity> addEntity(TestEntity entity) async{
    TestEntity addedEntity;
    logger.log(Level.info, "Called addEntity in Service");
    if(isOnline){
      //TODO logs
      addedEntity = await serverRepo.addEntity(entity);
    }
    else{
      //TODO logs
      addedEntity = await localRepo.addEntity(entity);
    }
    return addedEntity;
  }


  Future<TestEntity?> getById(int id) async {
    TestEntity? entity;
    logger.log(Level.info, "Called getById in Service with id: $id");
    if (isOnline) {
      logger.log(Level.info, "getById called on server");
      entity = await serverRepo.getById(id);
    } else {
      logger.log(Level.info, "getById called on local");
      entity = await localRepo.getEntityById(id);
    }
    logger.log(Level.info, "getById result: $entity");
    return entity;
  }

  Future<bool> deleteEntity(int id) async {
    bool result;
    logger.log(Level.info, "Called deleteEntity in Service with id: $id");
    if (isOnline) {
      logger.log(Level.info, "deleteEntity called on server");
      result = await serverRepo.deleteEntity(id);
    } else {
      logger.log(Level.info, "deleteEntity called on local");
      result = await localRepo.deleteEntity(id);
    }
    logger.log(Level.info, "deleteEntity result: $result");
    return result;
  }

  Future<bool> updateEntity(TestEntity entity) async {
    bool result;
    logger.log(Level.info, "Called updateEntity in Service with entity: $entity");
    if (isOnline) {
      logger.log(Level.info, "updateEntity called on server");
      result = await serverRepo.updateEntity(entity.id, entity);
    } else {
      logger.log(Level.info, "updateEntity called on local");
      result = await localRepo.updatedEntity(entity);
    }
    logger.log(Level.info, "updateEntity result: $result");
    return result;
  }

}