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
      // Offline-safe placeholder: no external platform dependency is required here.
      // In a real Android app, this can be replaced with a package such as flutter_tts.
      // The method stays non-throwing so the sorter remains functional offline.
      return;
    } catch (_) {
      return;
    }
  }
}
