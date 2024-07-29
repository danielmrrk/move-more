import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));

const kShowInstructions = 'show_instructions';

final instructionScreenProvider = StateNotifierProvider<InstructionScreenProvider, bool>((ref) => InstructionScreenProvider());

class InstructionScreenProvider extends StateNotifier<bool> {
  InstructionScreenProvider() : super(true) {
    _loadStateFromStorage();
  }

  void _loadStateFromStorage() async {
    final result = await storage.read(key: kShowInstructions);
    if (result == null) {
      return;
    }
    state = result == 'true';
  }

  void setShowInstructionScreen(bool show) {
    state = show;
    storage.write(key: kShowInstructions, value: state.toString());
  }
}
