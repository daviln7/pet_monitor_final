// lib/services/database_helper.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/pet_models.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pets.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // Se não for web, usa o caminho do diretório
    if (!kIsWeb) {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);
      return await openDatabase(path, version: 1, onCreate: _createDB);
    }
    // Se for WEB, usa a versão em memória que o ffi_web gerencia
    else {
      return await openDatabase(filePath, version: 1, onCreate: _createDB);
    }
  }

  Future _createDB(Database db, int version) async {
    // A criação da tabela só é relevante para plataformas não-web, mas não causa mal.
    await db.execute('''
      CREATE TABLE pets (
        id TEXT PRIMARY KEY,
        ownerId TEXT NOT NULL, -- Coluna adicionada para o ID do usuário
        name TEXT NOT NULL,
        breed TEXT NOT NULL, species TEXT NOT NULL, age INTEGER NOT NULL,
        avatarUrl TEXT, avatarFile TEXT, healthStatus TEXT NOT NULL,
        heartRateMin REAL NOT NULL, heartRateMax REAL NOT NULL,
        temperatureMin REAL NOT NULL, temperatureMax REAL NOT NULL, spo2Min REAL NOT NULL
      )
    ''');
  }

  // --- MÉTODOS CRUD MODIFICADOS ---

  // Agora, ao inserir, passamos o ID do dono
  Future<void> insertPet(Pet pet, String ownerId) async {
    if (kIsWeb) return; // Na web, não faz nada
    final db = await instance.database;
    final petMap = pet.toMap();
    petMap['ownerId'] = ownerId; // Garante que o ID do dono está no mapa
    await db.insert(
      'pets',
      petMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // A busca agora é filtrada pelo ID do dono
  Future<List<Pet>> getPets(String ownerId) async {
    if (kIsWeb) return []; // Na web, retorna uma lista vazia
    final db = await instance.database;
    final maps = await db.query(
      'pets',
      where: 'ownerId = ?', // Cláusula WHERE para filtrar
      whereArgs: [ownerId], // Argumento para a cláusula WHERE
    );
    return maps.isNotEmpty
        ? maps.map((json) => Pet.fromMap(json)).toList()
        : [];
  }

  Future<void> updatePet(Pet pet) async {
    if (kIsWeb) return; // Na web, não faz nada
    final db = await instance.database;
    await db.update('pets', pet.toMap(), where: 'id = ?', whereArgs: [pet.id]);
  }

  Future<void> deletePet(String id) async {
    if (kIsWeb) return; // Na web, não faz nada
    final db = await instance.database;
    await db.delete('pets', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    if (kIsWeb) return;
    final db = await instance.database;
    db.close();
  }
}
