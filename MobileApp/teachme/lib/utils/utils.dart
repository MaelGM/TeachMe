import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

String capitalize(String word) {
  if (word.isEmpty) return word;
  return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
}

String capitalizePhrase(String phrase) {
    if (phrase.trim().isEmpty) return phrase;

    return phrase
        .trim()
        .split(RegExp(r'\s+'))
        .map((word) =>
            word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }

ScaffoldMessageError(String text, BuildContext context) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.redAccent.shade200,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      duration: const Duration(seconds: 4),
    ),
  );
}

void initializeTimeagoLocales() {
  timeago.setLocaleMessages('es', timeago.EsMessages());
  timeago.setLocaleMessages('en', timeago.EnMessages());
  timeago.setLocaleMessages('fr', timeago.FrMessages());
  timeago.setLocaleMessages('de', timeago.DeMessages());
  timeago.setLocaleMessages('it', timeago.ItMessages());
  timeago.setLocaleMessages('pt', timeago.PtBrMessages());
  timeago.setLocaleMessages('zh', timeago.ZhCnMessages());
  timeago.setLocaleMessages('ja', timeago.JaMessages());
  timeago.setLocaleMessages('ko', timeago.KoMessages());
}

Color selectedColor = Color(0xFF3B82F6);
Color darkerColor = Color(0xFF151515);

final Map<String, IconData> specialtyIcons = {
  "functions": Icons.functions,
  "square_foot": Icons.square_foot,
  "calculate": Icons.calculate,
  "stacked_line_chart": Icons.stacked_line_chart,
  "grid_on": Icons.grid_on,
  "sports_mma": Icons.sports_mma,
  "highlight": Icons.highlight,
  "bolt": Icons.bolt,
  "device_thermostat": Icons.device_thermostat,
  "blur_on": Icons.blur_on,
  "science": Icons.science,
  "category": Icons.category,
  "bubble_chart": Icons.bubble_chart,
  "biotech": Icons.biotech,
  "fingerprint": Icons.fingerprint,
  "coronavirus": Icons.coronavirus,
  "eco": Icons.eco,
  "accessibility": Icons.accessibility,
  "menu_book": Icons.menu_book,
  "spellcheck": Icons.spellcheck,
  "edit": Icons.edit,
  "account_balance": Icons.account_balance,
  "history_edu": Icons.history_edu,
  "map": Icons.map,
  "terrain": Icons.terrain,
  "public": Icons.public,
  "balance": Icons.balance,
  "device_hub": Icons.device_hub,
  "psychology": Icons.psychology,
  "code": Icons.code,
  "router": Icons.router,
  "storage": Icons.storage,
  "sports": Icons.sports,
  "health_and_safety": Icons.health_and_safety,
  "show_chart": Icons.show_chart,
  "trending_up": Icons.trending_up,
  "brush": Icons.brush,
  "precision_manufacturing": Icons.precision_manufacturing,
  "design_services": Icons.design_services,
  "library_music": Icons.library_music,
  "queue_music": Icons.queue_music,
  "music_note": Icons.music_note,
  "smart_toy": Icons.smart_toy,
  "electrical_services": Icons.electrical_services,
  "record_voice_over": Icons.record_voice_over,
  "edit_note": Icons.edit_note,
  "hearing": Icons.hearing,
  "chat": Icons.chat,
  "text_snippet": Icons.text_snippet,
  "language": Icons.language,
  "flag": Icons.flag,
};

Map<String, IconData> iconSubjectsMap = {
  'calculate': Icons.calculate,
  'science': Icons.science,
  'biotech': Icons.biotech,
  'eco': Icons.eco,
  'menu_book': Icons.menu_book,
  'history_edu': Icons.history_edu,
  'public': Icons.public,
  'psychology': Icons.psychology,
  'computer': Icons.computer,
  'sports_soccer': Icons.sports_soccer,
  'account_balance': Icons.account_balance,
  'palette': Icons.palette,
  'music_note': Icons.music_note,
  'engineering': Icons.engineering,
  'g_translate': Icons.g_translate,
  'translate': Icons.translate,
  'language': Icons.language,
};