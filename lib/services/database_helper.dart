import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/pet_models.dart';

// Nota: Se você usa Firestore, este arquivo pode ser redundante.
// Mas para corrigir o erro de compilação, aqui está a versão ajustada.

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'pet_monitor.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE pets(
        id TEXT PRIMARY KEY,
        name TEXT,
        breed TEXT,
        species INTEGER,
        age INTEGER,
        avatarUrl TEXT,
        ownerId TEXT,
        healthStatus INTEGER,
        minTemp REAL,
        maxTemp REAL,
        minHeartRate REAL,
        maxHeartRate REAL,
        minSpo2 REAL
      )
    ''');
  }

  Future<int> insertPet(Pet pet) async {
    Database db = await database;
    // Converte o Pet para um Map plano para o SQLite
    Map<String, dynamic> map = pet.toMap();
    // Remove o mapa aninhado 'thresholds' e adiciona os campos planos
    map.remove('thresholds');
    map['minTemp'] = pet.thresholds.minTemp;
    map['maxTemp'] = pet.thresholds.maxTemp;
    map['minHeartRate'] = pet.thresholds.minHeartRate;
    map['maxHeartRate'] = pet.thresholds.maxHeartRate;
    map['minSpo2'] = pet.thresholds.minSpo2;

    return await db.insert('pets', map,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Pet>> getPets() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('pets');

    return List.generate(maps.length, (i) {
      // Reconstrói a estrutura de dados esperada pelo fromMap
      Map<String, dynamic> petMap = Map.from(maps[i]);
      petMap['thresholds'] = {
        'minTemp': maps[i]['minTemp'],
        'maxTemp': maps[i]['maxTemp'],
        'minHeartRate': maps[i]['minHeartRate'],
        'maxHeartRate': maps[i]['maxHeartRate'],
        'minSpo2': maps[i]['minSpo2'],
      };

      // CORREÇÃO AQUI: Passa o ID separadamente como segundo argumento
      return Pet.fromMap(petMap, maps[i]['id'].toString());
    });
  }
}
