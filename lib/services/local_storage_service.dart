import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

abstract class OfflineStorage {
  Future<Map<String, dynamic>> readJson(
    String key, {
    Map<String, dynamic>? fallback,
  });
  Future<void> writeJson(String key, Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> readCollection(String collectionName);
}

class AppLocalStorage implements OfflineStorage {
  static const String rootFolderName = 'agri_sorter_mobile';

  Future<Directory> _rootDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final directory = Directory('${appDir.path}/$rootFolderName');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  Future<File> _fileFor(String key) async {
    final directory = await _rootDirectory();
    return File('${directory.path}/$key.json');
  }

  @override
  Future<Map<String, dynamic>> readJson(
    String key, {
    Map<String, dynamic>? fallback,
  }) async {
    final file = await _fileFor(key);
    if (!await file.exists()) {
      return fallback ?? {};
    }

    try {
      final source = await file.readAsString();
      if (source.trim().isEmpty) {
        return fallback ?? {};
      }
      final decoded = jsonDecode(source);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return Map<String, dynamic>.from(decoded as Map);
    } on FormatException {
      return fallback ?? {};
    }
  }

  @override
  Future<void> writeJson(String key, Map<String, dynamic> data) async {
    final file = await _fileFor(key);
    await file.writeAsString(jsonEncode(data));
  }

  @override
  Future<List<Map<String, dynamic>>> readCollection(
    String collectionName,
  ) async {
    final directory = Directory(
      '${(await _rootDirectory()).path}/$collectionName',
    );
    if (!await directory.exists()) {
      return [];
    }

    final files = directory.listSync().whereType<File>().toList();
    final records = <Map<String, dynamic>>[];

    for (final file in files) {
      if (!file.path.endsWith('.json')) {
        continue;
      }
      final content = await file.readAsString();
      if (content.trim().isEmpty) {
        continue;
      }
      final decoded = jsonDecode(content);
      if (decoded is Map) {
        records.add(Map<String, dynamic>.from(decoded));
      }
    }

    return records;
  }
}
