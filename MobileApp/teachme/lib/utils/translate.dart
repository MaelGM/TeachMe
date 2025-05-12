import 'dart:ui';

import 'package:locale_names/locale_names.dart';
import 'package:teachme/models/country_model.dart';
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

String getPreferredLanguageCode(Pais pais) {
  if(pais.idiomas[0] == "Spanish") return "es";
  if(pais.idiomas[0] == "Portuguese") return "pt";
  if(pais.idiomas[0] == "Japanese") return "ja";

  for (var code in pais.codigosIdioma) {
    if (supportedLanguages.contains(code.substring(0, 2))) {
      return code.substring(0, 2); // ej: "en"
    }
  }
  return "en";
}