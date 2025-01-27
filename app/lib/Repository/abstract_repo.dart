import 'dart:io';

import 'package:app/Model/entity.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
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
      final path = join(dbPath, 'entity4.db');

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
      // Create a copy of the entity's JSON data
      Map<String, dynamic> entityData = entity.toJson();

      // Remove the id field if it exists
      entityData.remove('id');

      // Insert and get the auto-generated id
      final id = await db.insert("Exam", entityData);

      // Create a new entity with the assigned id
      TestEntity newEntity = TestEntity.fromJson({
        ...entityData,
        'id': id,
      });

      logger.log(Level.info, "addEntity() result: id $id");
      return newEntity;
    } catch (e) {
      logger.log(Level.error, "addEntity() failed: $e");
      rethrow; // Rethrow the error to handle it in the calling code
    }
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

  Future<bool> clearAllEntities() async {
    final db = await database;
    try {
      int count = await db.delete("Exam");
      logger.log(Level.info, "clearAllEntities() result: deleted $count entries");
      return true;
    } catch (e) {
      logger.log(Level.error, "clearAllEntities() failed: $e");
      return false;
    }
  }

  Future<bool> isTableEmpty() async {
  final db = await database;
  try {
    // Get the count of records
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM Exam');
    final count = Sqflite.firstIntValue(result) ?? 0;
    
    logger.log(Level.info, "isTableEmpty() check result: count = $count");
    return count == 0;
  } catch (e) {
    logger.log(Level.error, "isTableEmpty() check failed: $e");
    rethrow;
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
  }
}
