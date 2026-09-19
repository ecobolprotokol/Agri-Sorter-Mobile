import 'package:flutter_test/flutter_test.dart';
import 'package:agri_sorter_mobile/services/export_service.dart';
import 'package:agri_sorter_mobile/services/tts_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('tts service exposes real grade prompts and can speak text', () async {
    final tts = TtsService();

    expect(tts.getMessageFor('a'), 'Grade A');
    expect(tts.getPromptForFirmness(), 'Periksa firmness');

    await tts.speak('Grade A');
  });

  test('export service can generate a report file from rows', () async {
    final service = ExportService();
    final file = await service.exportReport(
      rows: [
        {
          'session_id': 'S1',
          'commodity': 'Pepaya',
          'grade': 'A',
          'count': 12,
          'percentage': 60,
        },
      ],
      fileName: 'report_test',
    );

    expect(file.existsSync(), isTrue);
    expect(file.path, contains('report_test'));
  });
}
