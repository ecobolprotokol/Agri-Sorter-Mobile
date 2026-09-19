import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class ExportService {
  Future<Directory> _resolveDirectory() async {
    try {
      return await getApplicationDocumentsDirectory();
    } catch (_) {
      final fallback = Directory.systemTemp.createTempSync('agri_sorter_export');
      return fallback;
    }
  }

  Future<File> exportCsv({
    required List<Map<String, dynamic>> rows,
    required String fileName,
  }) async {
    final dir = await _resolveDirectory();
    final file = File('${dir.path}/$fileName.csv');

    final headers = rows.isEmpty ? ['session_id', 'commodity', 'grade', 'count', 'percentage'] : rows.first.keys.toList();
    final buffer = StringBuffer();
    buffer.writeln(headers.join(','));

    for (final row in rows) {
      final values = headers.map((key) => '${row[key] ?? ''}'.replaceAll(',', ';')).toList();
      buffer.writeln(values.join(','));
    }

    await file.writeAsString(buffer.toString());
    return file;
  }

  Future<File> exportJson({
    required Map<String, dynamic> payload,
    required String fileName,
  }) async {
    final dir = await _resolveDirectory();
    final file = File('${dir.path}/$fileName.json');
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(payload));
    return file;
  }

  Future<File> exportReport({
    required List<Map<String, dynamic>> rows,
    required String fileName,
  }) async {
    final dir = await _resolveDirectory();
    final reportFile = File('${dir.path}/$fileName.json');
    await reportFile.writeAsString(
      const JsonEncoder.withIndent('  ').convert({
        'generated_at': DateTime.now().toIso8601String(),
        'rows': rows,
      }),
    );
    return reportFile;
  }
}
