import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:teachme/models/models.dart';

class UserPreferences {
  UserPreferences._internal();

  static final UserPreferences _instance = UserPreferences._internal();
  static UserPreferences get instance => _instance;
  static const _switchKey = 'notifications_enabled';
  set language(languageCode) => saveLanguage(languageCode);

  final FlutterSecureStorage _prefs = const FlutterSecureStorage();

  String? _refreshToken;
  String? get refreshToken => _refreshToken;

  Future<void> initPrefs() async {
    try {
      _refreshToken = await _prefs.read(key: 'refreshToken');
    } catch (e) {
      print("Error leyendo el refresh token: $e");
    }
  }

  Future<void> saveRefreshToken(String token) async {
    await _prefs.write(key: 'refreshToken', value: token);
    _refreshToken = token;
  }

  Future<void> deleteRefreshToken() async {
    await _prefs.delete(key: 'refreshToken');
    _refreshToken = null;
  }

  // Guarda el usuario en formato JSON en almacenamiento seguro
  Future<void> saveUser(UserModel user) async {
    final userJson = jsonEncode(user.toJson());
    await _prefs.write(key: 'user', value: userJson);
  }

  // Recupera el usuario almacenado
  Future<UserModel?> getUser() async {
    try {
      final userString = await _prefs.read(key: 'user');
      if (userString != null) {
        final userMap = jsonDecode(userString);
        return UserModel.fromJson(userMap);
      }
    } catch (e) {
      print("Error leyendo el usuario: $e");
    }
    return null;
  }

  Future<void> deleteUser() async {
    await _prefs.delete(key: 'user');
  }

  Future<void> saveLanguage(String languageCode) async {
    await _prefs.write(key: 'language', value: languageCode);
    print("Idioma guardado correctamente: $languageCode");
  }

  Future<String?> getLanguage() async {
    final language = await _prefs.read(key: 'language');
    print("Idioma leído correctamente: $language");
    return language;
  }

  static Future<void> saveSwitchValue(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_switchKey, value);
  }

  static Future<bool> getSwitchValue() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_switchKey) ?? false; // default false
  }

}
