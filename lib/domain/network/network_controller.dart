import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:movemore/domain/auth/token_service.dart';
import 'package:movemore/domain/onboarding/offline_screen.dart';
import 'package:movemore/domain/onboarding/welcome_screen.dart';
import 'package:movemore/domain/ranking/main_screen.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  static bool? _hasConnection;

  @override
  void onInit() {
    super.onInit();
    _connectivity.onConnectivityChanged.listen(_navigateBasedOnInternetConnection);
    hasNoConnection();
  }

  static Future<void> hasNoConnection() async {
    final result = await Connectivity().checkConnectivity();
    _navigateBasedOnInternetConnection(result);
  }

  static void _navigateBasedOnInternetConnection(ConnectivityResult result) async {
    bool hasConnection = result != ConnectivityResult.none;
    if (!hasConnection) {
      _hasConnection = false;
      Get.offAll(() => const OfflineScreen(), duration: Duration.zero);
    } else if (_hasConnection != true) {
      _hasConnection = true;
      await tokenService.tryLoginAfterRestart();
      if (tokenService.isLoggedIn()) {
        Get.offAll(() => const MainScreen(), duration: Duration.zero);
      } else {
        Get.offAll(() => const WelcomeScreen(), duration: Duration.zero);
      }
    }
  }
}
