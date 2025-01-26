import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:app/Model/entity.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:sqflite/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class Abstractrepo {
  Database? _database;
  static Logger logger = Logger();
  Abstractrepo();

  Future<void> initDb() async {
    try {
      if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'entity.db');

      if (_database != null) return;

      String createString = 'CREATE TABLE EXAM( ';
      Map<String, dynamic> attributes = TestEntity.toDatabaseAttributes();
      attributes.forEach((key, value) {
        if (key != 'id') {
          createString += ',';
        }
        createString += key + value;
      });
      createString += ' );';
      print(createString);

      _database = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute(createString);
        },
      );
      await _addMockData();
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  Future<Database> get database async {
    if (_database == null) {
      await initDb();
    }
    return _database!;
  }

  Future<List<TestEntity>> getAllEntities() async {
    final db = await database;
    final result = await db.query('Exam');
    logger.log(Level.info, "getAll() result: $result");
    return result.map((json) => TestEntity.fromJson(json)).toList();
  }

  Future<TestEntity> addEntity(TestEntity entity) async {
    final db = await database;
    try {
      final id = await db.insert("Exam", entity.toJson());
      logger.log(Level.info, "addEntity() result: id $id");
    } catch (e) {
      logger.log(Level.error, "addEntity() failed: $e");
    }
    return entity;
  }

  Future<bool> deleteEntity(int id) async {
    final db = await database;
    try {
      int count = await db.delete("Exam", where: "id =?", whereArgs: [id]);
      logger.log(Level.info, "deleteEntity() result: deleted $count entries");
      return true;
    } catch (e) {
      logger.log(Level.error, "deleteEntity() failed: $e");
      return false;
    }
  }

  Future<bool> updatedEntity(TestEntity newEntity) async {
    final db = await database;
    try {
      int changes = await db.update("Exam", newEntity.toJson(),
          where: "id =?", whereArgs: [newEntity.id]);
      logger.log(Level.info, "updateEntity() result: made $changes changes");
      return true;
    } catch (e) {
      logger.log(Level.error, "updateEntity() error: $e");
      return false;
    }
  }

  Future<TestEntity?> getEntityById(int id) async{
    final db = await database;
    try{
      final entity = await db.query("Exam",where: "id=?",whereArgs: [id]);
      logger.log(Level.info, "getEntityById result: $entity");
      final result = entity.map((json) => TestEntity.fromJson(json)).toList();
      return result[0];
    }catch(e){
      logger.log(Level.error, "getEntityById error : $e");
      return null;
    }
  }

  Future<void> _addMockData() async {
    final db = await database;

    // Insert mock data
    await db.insert(
      'EXAM',
      {'id': 1, 'name': 'John Doe'},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await db.insert(
      'EXAM',
      {'id': 2, 'name': 'Jane Smith'},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    print("Mock data added to EXAM table.");
  }
}
