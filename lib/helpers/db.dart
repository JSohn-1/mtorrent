import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../servers/models/server.dart';

class Db {
  factory Db() => _instance;
  Db._internal();
  static final Db _instance = Db._internal();

  Database? _database;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    final path = join(await getDatabasesPath(), 'app_database.db');
    _database = await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE servers(id INTEGER PRIMARY KEY, label TEXT, url TEXT, username TEXT, password TEXT, type TEXT)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('DROP TABLE IF EXISTS servers');
          await db.execute(
            'CREATE TABLE servers(id INTEGER PRIMARY KEY, label TEXT, url TEXT, username TEXT, password TEXT, type TEXT)',
          );
        }
      },
    );
    return _database!;
  }

  Future<void> insertServer(Server server) async {
    final db = await database;
    final data = <String, dynamic>{
      'url': server.url,
      'label': server.label,
      'username': server.username,
      'password': server.password,
      'type': server.type,
    };
    if (server.id != null) {
      data['id'] = server.id;
    }
    await db.insert('servers', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Server>> getServers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('servers');

    return List.generate(maps.length, (i) => Server(
        id: maps[i]['id'],
        url: maps[i]['url'],
        label: maps[i]['label'],
        username: maps[i]['username'],
        password: maps[i]['password'],
        type: maps[i]['type'],
      ));
  }

  Future<void> deleteServer(int id) async {
    final db = await database;
    await db.delete('servers', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> storeSecureData(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> retrieveSecureData(String key) async => _secureStorage.read(key: key);

  Future<void> deleteSecureData(String key) async {
    await _secureStorage.delete(key: key);
  }

  Future<void> resetDatabase() async {
    final db = await database;
    await db.execute('DROP TABLE IF EXISTS servers');
    await db.execute(
      'CREATE TABLE servers(id INTEGER PRIMARY KEY, label TEXT, url TEXT, username TEXT, password TEXT, type TEXT)',
    );
  }
}
