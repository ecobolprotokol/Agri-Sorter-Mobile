class TtsService {
  final List<String> offlinePhrases = [
    'Periksa firmness',
    'Grade A',
    'Grade B',
    'Afkir',
    'Objek tidak terdeteksi',
    'Silakan ulangi',
  ];

  String getMessageFor(String grade) {
    switch (grade.toUpperCase()) {
      case 'A':
        return 'Grade A';
      case 'B':
        return 'Grade B';
      case 'REJECT':
      case 'AFKIR':
        return 'Afkir';
      default:
        return 'Silakan ulangi';
    }
  }

  String getPromptForFirmness() => 'Periksa firmness';

  Future<void> speak(String text) async {
    final message = text.trim();
    if (message.isEmpty) {
      return;
    }

    try {
      return;
    } catch (_) {
      return;
    }
  }
}
