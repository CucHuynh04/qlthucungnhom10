// lib/locale_service.dart

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService extends ChangeNotifier {
  Locale _locale = const Locale('vi', 'VN');

  Locale get locale => _locale;

  LocaleService() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code');
    final countryCode = prefs.getString('country_code');
    
    if (languageCode != null && countryCode != null) {
      _locale = Locale(languageCode, countryCode);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    // Chỉ so sánh language code, không so sánh country code
    if (_locale.languageCode == locale.languageCode) return;
    
    _locale = locale;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    await prefs.setString('country_code', locale.countryCode ?? '');
    
    // Cập nhật locale trong easy_localization
    final context = navigatorKey.currentContext;
    if (context != null) {
      try {
        await context.setLocale(locale);
        debugPrint('Locale changed to: ${locale.languageCode}');
      } catch (e) {
        debugPrint('Error setting locale: $e');
      }
    }
    
    notifyListeners();
  }
  
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  List<Locale> get supportedLocales => [
    const Locale('vi', 'VN'), // Tiếng Việt
    const Locale('en', 'US'), // English
  ];
}






