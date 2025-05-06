import 'dart:ui';

import 'package:locale_names/locale_names.dart';
import 'package:teachme/utils/utils.dart';
import 'package:teachme/widgets/app_localizations.dart';

String translate(context, key) {
  return AppLocalizations.of(context).translate(context, key);
}

final List<String> supportedLanguages = ['en', 'es', 'fr', 'de', 'it', 'pt', 'zh', 'ja', 'ko'];

String getDisplayLanguage(String langCode, Locale currentLocale) {
  final locale = Locale(langCode);
  return locale.displayLanguageIn(currentLocale);
}

String getNativeDisplayLanguage(String langCode) {
  final native = Locale(langCode).nativeDisplayLanguage;
  return capitalize(native);
}