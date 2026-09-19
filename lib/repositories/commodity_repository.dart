import 'package:sqflite/sqflite.dart';

import '../models/commodity.dart';
import '../services/local_database_service.dart';

class CommodityRepository {
  CommodityRepository(this.databaseService);

  final LocalDatabaseService databaseService;

  Future<List<Commodity>> fetchAll() async {
    final db = await databaseService.database;
    final defaultItems = [
      Commodity(
        id: 'papaya_california',
        name: 'Pepaya',
        variety: 'California',
        version: 3,
        features: {
          'color': {'hue_mean': 42.5},
          'geometry': {'aspect_ratio': 1.42},
        },
        grades: {
          'A': {'threshold': 0.8},
          'B': {'threshold': 0.5},
          'REJECT': {'threshold': 0.3},
        },
        firmness: {'FIRM': '1', 'MEDIUM': '2', 'SOFT': '3'},
        calibration: {
          'sample_count': 120,
          'calibrated_at': DateTime.now().toIso8601String(),
        },
      ),
      Commodity(
        id: 'tomato',
        name: 'Tomat',
        variety: 'Regular',
        version: 2,
        features: {
          'color': {'hue_mean': 20.0},
          'geometry': {'circularity': 0.72},
        },
        grades: {
          'A': {'threshold': 0.82},
          'B': {'threshold': 0.6},
          'REJECT': {'threshold': 0.4},
        },
        firmness: {'FIRM': '1', 'MEDIUM': '2', 'SOFT': '3'},
        calibration: {
          'sample_count': 90,
          'calibrated_at': DateTime.now().toIso8601String(),
        },
      ),
      Commodity(
        id: 'orange_keprok',
        name: 'Jeruk',
        variety: 'Keprok',
        version: 2,
        features: {
          'color': {'hue_mean': 32.0},
          'geometry': {'circularity': 0.78},
        },
        grades: {
          'A': {'threshold': 0.84},
          'B': {'threshold': 0.6},
          'REJECT': {'threshold': 0.4},
        },
        firmness: {'FIRM': '1', 'MEDIUM': '2', 'SOFT': '3'},
        calibration: {
          'sample_count': 86,
          'calibrated_at': DateTime.now().toIso8601String(),
        },
      ),
      Commodity(
        id: 'mango_harum_manis',
        name: 'Mangga',
        variety: 'Harum Manis',
        version: 2,
        features: {
          'color': {'hue_mean': 48.0},
          'geometry': {'aspect_ratio': 1.55},
        },
        grades: {
          'A': {'threshold': 0.85},
          'B': {'threshold': 0.62},
          'REJECT': {'threshold': 0.42},
        },
        firmness: {'FIRM': '1', 'MEDIUM': '2', 'SOFT': '3'},
        calibration: {
          'sample_count': 74,
          'calibrated_at': DateTime.now().toIso8601String(),
        },
      ),
      Commodity(
        id: 'chili_red',
        name: 'Cabai',
        variety: 'Merah Keriting',
        version: 1,
        features: {
          'color': {'hue_mean': 8.0},
          'geometry': {'aspect_ratio': 3.4},
        },
        grades: {
          'A': {'threshold': 0.8},
          'B': {'threshold': 0.55},
          'REJECT': {'threshold': 0.35},
        },
        firmness: {'FIRM': '1', 'MEDIUM': '2', 'SOFT': '3'},
        calibration: {
          'sample_count': 62,
          'calibrated_at': DateTime.now().toIso8601String(),
        },
      ),
      Commodity(
        id: 'banana_cavendish',
        name: 'Pisang',
        variety: 'Cavendish',
        version: 1,
        features: {
          'color': {'hue_mean': 54.0},
          'geometry': {'aspect_ratio': 2.6},
        },
        grades: {
          'A': {'threshold': 0.82},
          'B': {'threshold': 0.58},
          'REJECT': {'threshold': 0.38},
        },
        firmness: {'FIRM': '1', 'MEDIUM': '2', 'SOFT': '3'},
        calibration: {
          'sample_count': 68,
          'calibrated_at': DateTime.now().toIso8601String(),
        },
      ),
      Commodity(
        id: 'avocado_alpukat',
        name: 'Alpukat',
        variety: 'Mentega',
        version: 1,
        features: {
          'color': {'hue_mean': 78.0},
          'geometry': {'circularity': 0.74},
        },
        grades: {
          'A': {'threshold': 0.83},
          'B': {'threshold': 0.6},
          'REJECT': {'threshold': 0.4},
        },
        firmness: {'FIRM': '1', 'MEDIUM': '2', 'SOFT': '3'},
        calibration: {
          'sample_count': 55,
          'calibrated_at': DateTime.now().toIso8601String(),
        },
      ),
    ];

    for (final item in defaultItems) {
      await db.insert(
        'commodities',
        item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    final rows = await db.query('commodities', orderBy: 'created_at DESC');
    return rows.map((row) => Commodity.fromMap(row)).toList();
  }

  Future<Commodity> create(Commodity commodity) async {
    final db = await databaseService.database;
    final map = commodity.toMap();
    await db.insert(
      'commodities',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return commodity;
  }

  Future<void> delete(String id) async {
    final db = await databaseService.database;
    await db.delete('commodities', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> update(Commodity commodity) async {
    final db = await databaseService.database;
    await db.update(
      'commodities',
      commodity.toMap(),
      where: 'id = ?',
      whereArgs: [commodity.id],
    );
  }
}
