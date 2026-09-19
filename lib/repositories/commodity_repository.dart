import 'package:sqflite/sqflite.dart';

import '../models/commodity.dart';
import '../services/local_database_service.dart';

class CommodityRepository {
  CommodityRepository(this.databaseService);

  final LocalDatabaseService databaseService;

  Future<List<Commodity>> fetchAll() async {
    final db = await databaseService.database;
    final rows = await db.query('commodities', orderBy: 'created_at DESC');

    if (rows.isEmpty) {
      final defaultItems = [
        Commodity(
          id: 'papaya_california',
          name: 'Pepaya',
          variety: 'California',
          version: 3,
          features: {'color': {'hue_mean': 42.5}, 'geometry': {'aspect_ratio': 1.42}},
          grades: {'A': {'threshold': 0.8}, 'B': {'threshold': 0.5}, 'REJECT': {'threshold': 0.3}},
          firmness: {'FIRM': '1', 'MEDIUM': '2', 'SOFT': '3'},
          calibration: {'sample_count': 120, 'calibrated_at': DateTime.now().toIso8601String()},
        ),
        Commodity(
          id: 'tomato',
          name: 'Tomat',
          variety: 'Regular',
          version: 2,
          features: {'color': {'hue_mean': 20.0}, 'geometry': {'circularity': 0.72}},
          grades: {'A': {'threshold': 0.82}, 'B': {'threshold': 0.6}, 'REJECT': {'threshold': 0.4}},
          firmness: {'FIRM': '1', 'MEDIUM': '2', 'SOFT': '3'},
          calibration: {'sample_count': 90, 'calibrated_at': DateTime.now().toIso8601String()},
        ),
      ];

      for (final item in defaultItems) {
        await db.insert('commodities', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      }
      return defaultItems;
    }

    return rows.map((row) => Commodity.fromMap(row)).toList();
  }

  Future<Commodity> create(Commodity commodity) async {
    final db = await databaseService.database;
    final map = commodity.toMap();
    await db.insert('commodities', map, conflictAlgorithm: ConflictAlgorithm.replace);
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
