import 'package:sqflite/sqflite.dart';

import '../models/commodity.dart';
import '../models/dataset_sample.dart';
import '../models/sorting_result.dart';
import '../models/sorting_session.dart';
import '../repositories/commodity_repository.dart';
import '../repositories/sorting_repository.dart';
import '../services/local_database_service.dart';

class AppRepository {
  AppRepository() : _db = LocalDatabaseService.instance;

  final LocalDatabaseService _db;

  late final CommodityRepository commodities = CommodityRepository(_db);
  late final SortingRepository sorting = SortingRepository(_db);

  Future<List<Commodity>> loadCommodities() => commodities.fetchAll();

  Future<List<SortingSession>> loadSessions() => sorting.fetchSessions();

  Future<List<SortingResult>> loadResults() => sorting.fetchResults();

  Future<Commodity> saveCommodity(Commodity commodity) =>
      commodities.create(commodity);

  Future<SortingSession> createSession({
    required String commodity,
    required String operator,
    required String location,
  }) => sorting.createSession(
    commodity: commodity,
    operator: operator,
    location: location,
  );

  Future<SortingResult> addResult({required SortingResult result}) =>
      sorting.saveResult(result: result);

  Future<void> addDatasetSample(DatasetSample sample) async {
    final db = await _db.database;
    await db.insert(
      'dataset_samples',
      sample.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<DatasetSample>> loadDatasetSamples(String commodityId) async {
    final db = await _db.database;
    final rows = await db.query(
      'dataset_samples',
      where: 'commodity_id = ?',
      whereArgs: [commodityId],
      orderBy: 'created_at DESC',
    );

    return rows
        .map((row) => DatasetSample.fromMap(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<void> deleteDatasetSample(String id) async {
    final db = await _db.database;
    await db.delete('dataset_samples', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateDatasetSampleLabel({required String id, required String label}) async {
    final db = await _db.database;
    await db.update('dataset_samples', {'label': label}, where: 'id = ?', whereArgs: [id]);
  }
}
