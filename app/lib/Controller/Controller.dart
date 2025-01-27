import 'package:app/Model/entity.dart';
import 'package:app/Repository/abstract_repo.dart';
import 'package:app/Repository/server_repo.dart';
import 'package:logger/logger.dart';

class Controller {
  final Abstractrepo localRepo;
  final ServerRepo serverRepo;
  final Function isOnline;

  static Controller? _instance;
  static Logger logger = Logger();

  Controller._({
    required this.localRepo,
    required this.serverRepo,
    required this.isOnline,
  });

  static void initialize({
    required Abstractrepo localRepo,
    required ServerRepo serverRepo,
    required Function isOnline,
  }) {
    _instance ??= Controller._(
        localRepo: localRepo,
        serverRepo: serverRepo,
        isOnline: isOnline,
      );
  }

  static Controller get instance {
    if (_instance == null) {
      throw Exception(
          'Controller has not been initialized. Call initialize() first.');
    }
    return _instance!;
  }

  Controller._internal(
      {required this.localRepo,
      required this.serverRepo,
      required this.isOnline});

  factory Controller(
      {required Abstractrepo localRepo,
      required ServerRepo serverRepo,
      required Function isOnline}) {
    if (_instance == null) {
      _instance = Controller._internal(
          localRepo: localRepo, serverRepo: serverRepo, isOnline: isOnline);
    } else {
      if (_instance!.localRepo != localRepo ||
          _instance!.serverRepo != serverRepo ||
          _instance!.isOnline != isOnline) {
        throw Exception(
            "Controller is already initialized with different parameters.");
      }
    }
    return _instance!;
  }

  Future<List<TestEntity>> getAllEntities() async {
    List<TestEntity> entities = [];
    logger.log(Level.info, "Called getAllEntities in Service");
    if (isOnline()) {
      entities = await serverRepo.getAllEntities();
      logger.log(
          Level.info, "getAllEntities called from server result: $entities");
    } else {
      entities = await localRepo.getAllEntities();
      logger.log(
          Level.info, "getAllEntities called from local result: $entities");
    }
    return entities;
  }

  Future<TestEntity> addEntity(TestEntity entity) async {
    TestEntity addedEntity;
    logger.log(Level.info, "Called addEntity in Service");
    if (isOnline()) {
      logger.log(Level.info, "addEntity called on server");
      addedEntity = await serverRepo.addEntity(entity);
    } else {
      logger.log(Level.info, "addEntity called on local");
      addedEntity = await localRepo.addEntity(entity);
    }
    logger.log(Level.info, "addEntity result: $entity");
    return addedEntity;
  }

  Future<TestEntity?> getById(int id) async {
    TestEntity? entity;
    logger.log(Level.info, "Called getById in Service with id: $id");
    if (isOnline()) {
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
    if (isOnline()) {
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
    logger.log(
        Level.info, "Called updateEntity in Service with entity: $entity");
    if (isOnline()) {
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
