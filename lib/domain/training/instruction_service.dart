import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));

const kShowInstructions = 'show_instructions';

final instructionScreenService = InstructionScreenService();

class InstructionScreenService {
  InstructionScreenService();

  bool? _showScreen;

  Future<bool> loadStateFromStorage() async {
    if (_showScreen == null) {
      final result = await storage.read(key: kShowInstructions);
      _showScreen = result != 'false';
    }
    return _showScreen!;
  }

  void setShowInstructionScreen(bool show) {
    _showScreen = show;
    storage.write(key: kShowInstructions, value: _showScreen.toString());
  }
}
