import 'dart:io';

class DotEnvService {
  final Map<String, String> _map = {};
  static DotEnvService instance = DotEnvService._();

  DotEnvService._() {
    _init();
  }

  void _init() {
    final file = File('.env');
    final envText = file.readAsStringSync();

    for (var line in envText.trim().split('\n')) {
      final lineBreak = line.split('=');
      print(lineBreak);
      print('${lineBreak[0]} ${lineBreak[1]}');
      _map[lineBreak[0]] = lineBreak[1];
    }
  }

  String? operator [](String key) {
    return _map[key];
  }
}
