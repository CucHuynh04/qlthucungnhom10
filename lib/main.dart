// lib/main.dart

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'login_screen.dart'; 
import 'pet_service.dart';
import 'notification_service.dart';
import 'locale_service.dart';
import 'theme_service.dart';
import 'background_music_service.dart';

// Top-level function for handling background messages
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background message
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize easy_localization
  await EasyLocalization.ensureInitialized();
  
  // Initialize Firebase with options
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    // Handle Firebase initialization error
    debugPrint('Firebase initialization error: $e');
    // App will still work, but chat feature won't be available
  }
  
  // Bọc (wrap) toàn bộ ứng dụng bằng MultiProvider để cấp quyền truy cập các service
  runApp(
    EasyLocalization(
      path: 'assets/translations',
      supportedLocales: const [Locale('en'), Locale('vi')],
      fallbackLocale: const Locale('vi'),
      startLocale: const Locale('vi'),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => LocaleService()),
          ChangeNotifierProvider(create: (context) => ThemeService()),
          ChangeNotifierProvider(create: (context) => PetService()),
          ChangeNotifierProvider(create: (context) => NotificationService()),
          ChangeNotifierProvider(create: (context) => BackgroundMusicService()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize FCM when app starts
      final notificationService = context.read<NotificationService>();
      final petService = context.read<PetService>();
      notificationService.initialize();
      
      // Schedule vaccination notifications
      notificationService.scheduleAllVaccinationNotifications(petService);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return MaterialApp(
          navigatorKey: LocaleService.navigatorKey,
          title: 'app_title'.tr(),
          theme: themeService.lightTheme,
          darkTheme: themeService.darkTheme,
          themeMode: themeService.themeMode,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          // Giữ nguyên logic khởi đầu bằng màn hình đăng nhập
          home: const LoginScreen(), 
        );
      },
    );
  }
}




