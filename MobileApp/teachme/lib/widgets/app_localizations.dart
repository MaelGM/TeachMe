import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:teachme/utils/translate.dart';

class AppLocalizations {
  final Locale locale;
  Map<String, String>? _localizedStrings;
  Map<String, String>? _defaultLocalizedStrings;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Future<bool> load() async {
    String jsonString = await rootBundle.loadString(
      'assets/lang/${locale.languageCode}.json',
    );
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedStrings = jsonMap.map(
      (key, value) => MapEntry(key, value.toString()),
    );

    String englishJsonString = await rootBundle.loadString('assets/lang/en.json');
    Map<String, dynamic> englishJsonMap = json.decode(englishJsonString);
    _defaultLocalizedStrings = englishJsonMap.map(
      (key, value) => MapEntry(key, value.toString()),
    );

    return true;
  }

  String translate(context, String key) {
    return _localizedStrings?[key] ?? _defaultLocalizedStrings?[key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => supportedLanguages.contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
