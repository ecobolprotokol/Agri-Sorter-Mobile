import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class LocalDatabaseService {
  LocalDatabaseService._internal();

  static final LocalDatabaseService instance = LocalDatabaseService._internal();

  static Database? _database;
  static bool _ffiInitialized = false;

  static void _ensureFfiInitialized() {
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      if (!_ffiInitialized) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
        _ffiInitialized = true;
      }
    }
  }

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _ensureFfiInitialized();

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'agri_sorter.db');

    return openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE commodities (
        id TEXT PRIMARY KEY,
        name TEXT,
        variety TEXT,
        version INTEGER,
        method TEXT,
        features TEXT,
        grades TEXT,
        firmness TEXT,
        calibration TEXT,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE sorting_sessions (
        id TEXT PRIMARY KEY,
        started_at TEXT,
        finished_at TEXT,
        operator TEXT,
        location TEXT,
        commodity TEXT,
        total_items INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE sorting_results (
        result_id TEXT PRIMARY KEY,
        session_id TEXT,
        commodity_id TEXT,
        profile_version INTEGER,
        grade TEXT,
        confidence REAL,
        firmness TEXT,
        timestamp TEXT,
        ripe_percentage REAL,
        image_path TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE dataset_samples (
        id TEXT PRIMARY KEY,
        commodity_id TEXT,
        label TEXT,
        image_path TEXT,
        created_at TEXT
      )
    ''');
  }
}
