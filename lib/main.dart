import 'package:eraser/eraser.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:movemore/domain/auth/token_service.dart';
import 'package:movemore/domain/friend/friend_screen.dart';
import 'package:movemore/domain/friend/friend_toggle_bar.dart';
import 'package:movemore/domain/network/network_controller.dart';
import 'package:movemore/domain/onboarding/splash_screen.dart';
import 'package:movemore/domain/ranking/main_screen.dart';

import 'package:movemore/general/theme/color_theme.dart';
import 'package:movemore/general/theme/text_style_theme.dart';
import 'package:movemore/general/util/navigation.dart';

const ColorScheme kColorScheme = ColorScheme.dark(
  primary: Color(0xff8db538),
  onPrimary: Color(0xffFCFCFC),
  secondary: Color(0xffFFA94D),
  onSecondary: Color(0xffFFA94D),
  background: Color(0xff33394D),
  onBackground: Color(0xffFCFCFC),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  Eraser.clearAllAppNotifications();
  await Firebase.initializeApp();
  await tokenService.tryLoginAfterRestart();
  runApp(const ProviderScope(child: MoveMoreApp()));
  Get.put(NetworkController(), permanent: true);
}

class MoveMoreApp extends ConsumerStatefulWidget {
  const MoveMoreApp({super.key});

  @override
  ConsumerState<MoveMoreApp> createState() => _MoveMoreAppState();
}

class _MoveMoreAppState extends ConsumerState<MoveMoreApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupNotificationTapHandler();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Eraser.clearAllAppNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: const SplashScreen(),
      title: 'MoveMore',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: kColorScheme,
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: kColorScheme.onBackground,
            textStyle: const TextStyle(decoration: TextDecoration.underline),
          ),
        ),
        textTheme: const TextTheme(
          labelLarge: TextStyle(fontSize: 18),
        ),
        appBarTheme: AppBarTheme(backgroundColor: Colors.transparent, titleTextStyle: MMTextStyleTheme.standardLarge),
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: const EdgeInsets.symmetric(horizontal: 48),
          fillColor: MMColorTheme.blue800,
          filled: true,
          errorStyle: const TextStyle(fontSize: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(100), borderSide: BorderSide.none),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: MMColorTheme.blue800,
          contentTextStyle: MMTextStyleTheme.standardSmall,
        ),
      ),
    );
  }

  void _setupNotificationTapHandler() {
    FirebaseMessaging.onMessageOpenedApp.listen((notification) {
      if (notification.data.containsKey('exerciseId')) {
        final exerciseId = int.parse(notification.data['exerciseId']);
        navigateTo(
          MainScreen(
            selectedExerciseId: exerciseId,
          ),
          context,
        );
      } else if (notification.data.containsKey('friendName')) {
        navigateTo(const FriendScreen(initialPage: FriendPage.friendList), context);
      } else if (notification.data.containsKey('senderName')) {
        navigateTo(const FriendScreen(), context);
      }
    });
  }
}
