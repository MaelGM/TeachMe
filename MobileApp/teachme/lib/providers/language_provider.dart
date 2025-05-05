import 'package:flutter/material.dart';
import 'package:teachme/utils/translate.dart';
import 'package:teachme/utils/user_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = Locale('en'); 

  Locale get locale => _locale;

  LanguageProvider() {
    print("cargando idioma...");
    loadLanguage();
  }

  void loadLanguage() async {
    String? savedLang = await UserPreferences.instance.getLanguage();
    print("Idioma guardado: ${savedLang ?? 'null'}");

    if (savedLang == null || savedLang.isEmpty) {
      print("No existe idioma guardado, se usará el idioma del sistema.");
      final systemLang =
          WidgetsBinding.instance.platformDispatcher.locale.languageCode;

      if (supportedLanguages.contains(systemLang)) {
        print("Asignando idioma del sistema: $systemLang");
        savedLang = systemLang;
      } else {
        print("Asignando idioma por defecto: en");
        savedLang = 'en';
      }

      await UserPreferences.instance.saveLanguage(savedLang);
    }

    _locale = Locale(savedLang);
    notifyListeners();
  }

  void setLanguage(String languageCode) async {
    _locale = Locale(languageCode);
    UserPreferences.instance.language = languageCode;
    notifyListeners();
  }
}
