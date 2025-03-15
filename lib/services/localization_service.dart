import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService {
  static const Locale defaultLocale = Locale('en');

  static List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('ml'), // Malayalam
    Locale('ta'), // Tamil
    Locale('hi'), // Hindi
  ];

  static Future<Locale> getSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    String? localeCode = prefs.getString('selected_locale');
    return localeCode != null ? Locale(localeCode) : defaultLocale;
  }

  static Future<void> saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_locale', locale.languageCode);
  }

  static Future<Map<String, String>> loadLanguage(String langCode) async {
    try {
      final String jsonString = await rootBundle.loadString(
        'lib/localization/$langCode.json',
      );
      final Map<String, dynamic> jsonMap = json.decode(jsonString);

      // Ensure it returns Map<String, String>
      return jsonMap.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      print(
        "❌ Error loading localization file: Unable to load asset lib/localization/$langCode.json.",
      );
      return {"welcome": "Welcome, {username}!"}; // Default fallback
    }
  }
}
