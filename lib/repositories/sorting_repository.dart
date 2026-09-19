import 'package:sqflite/sqflite.dart';

import '../models/sorting_result.dart';
import '../models/sorting_session.dart';
import '../services/local_database_service.dart';

class SortingRepository {
  SortingRepository(this.databaseService);

  final LocalDatabaseService databaseService;

  Future<List<SortingSession>> fetchSessions() async {
    final db = await databaseService.database;
    final rows = await db.query('sorting_sessions', orderBy: 'started_at DESC');
    return rows
        .map((row) => SortingSession.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<List<SortingResult>> fetchResults() async {
    final db = await databaseService.database;
    final rows = await db.query('sorting_results', orderBy: 'timestamp DESC');
    return rows
        .map((row) => SortingResult.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<SortingSession> createSession({
    required String commodity,
    required String operator,
    required String location,
  }) async {
    final db = await databaseService.database;
    final session = SortingSession(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      startedAt: DateTime.now(),
      operator: operator,
      location: location,
      commodity: commodity,
      totalItems: 0,
    );

    await db.insert(
      'sorting_sessions',
      session.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return session;
  }

  Future<SortingResult> saveResult({required SortingResult result}) async {
    final db = await databaseService.database;
    await db.insert(
      'sorting_results',
      result.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    final session = await db.query(
      'sorting_sessions',
      where: 'id = ?',
      whereArgs: [result.sessionId],
      limit: 1,
    );

    if (session.isNotEmpty) {
      final current = session.first['total_items'] as int? ?? 0;
      await db.update(
        'sorting_sessions',
        {'total_items': current + 1},
        where: 'id = ?',
        whereArgs: [result.sessionId],
      );
    }

    return result;
  }

  Future<void> finishSession(String sessionId) async {
    final db = await databaseService.database;
    await db.update(
      'sorting_sessions',
      {'finished_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }
}
