import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teachme/models/country_model.dart';
import 'dart:convert';

import 'package:teachme/models/models.dart';
import 'package:teachme/models/skill_model.dart';

class UserPreferences {
  static late Box _box;
  static final _firestore = FirebaseFirestore.instance;
  UserPreferences._internal();

  static final UserPreferences _instance = UserPreferences._internal();
  static UserPreferences get instance => _instance;
  static const _switchKey = 'notifications_enabled';
  set language(languageCode) => saveLanguage(languageCode);

  final FlutterSecureStorage _prefs = const FlutterSecureStorage();

  String? _refreshToken;
  String? get refreshToken => _refreshToken;

  Future<void> initPrefs() async {
    _box = await Hive.openBox('local_storage');
    await _loadCountriesIfNeeded();
    await _loadSkillsIfNeeded();
    try {
      _refreshToken = await _prefs.read(key: 'refreshToken');
    } catch (e) {
      print("Error leyendo el refresh token: $e");
    }
  }

  /*
    Se revisa si ya están las habilidades en la BD local del dispositivo,
    y si no lo estaban, se guardan.
  */
  static Future<void> _loadSkillsIfNeeded() async {
    if (!_box.containsKey('skills')) {
      try {
        final snapshot = await _firestore.collection('skills').get();
        final List<Map<String, dynamic>> skillList = snapshot.docs
            .map((doc) => {'name': doc['name']})
            .toList();

        final encoded = json.encode(skillList);
        await _box.put('skills', encoded);

        print("Skills descargadas y guardadas localmente.");
      } catch (e) {
        print("Error cargando skills desde Firestore: $e");
        throw Exception("No se pudieron cargar las skills");
      }
    } else {
      print("Skills ya estaban guardadas");
    }
  }

  /// Devuelve las skills en JSON crudo (como List<dynamic>)
  static List<dynamic> getSkillsJson() {
    final String? jsonData = _box.get('skills');
    if (jsonData == null) return [];
    return json.decode(jsonData);
  }

  /// Devuelve las skills como lista de objetos Skill
  static List<Skill> getSkills() {
    final String? jsonData = _box.get('skills');
    if (jsonData == null) return [];

    List<Skill> skills = [];
    final List<dynamic> decoded = json.decode(jsonData);

    for (final e in decoded) {
      if (e is Map) {
        try {
          skills.add(Skill.fromJson(Map<String, dynamic>.from(e)));
        } catch (err) {
          print("Error parseando skill: $err");
        }
      }
    }

    return skills;
  }


  /*
    Se revisa si ya estan los paises en la BD local del dispositivo, y si no lo estaban, se guardan.
    De esta manera evitamos muchas peticiones.
  */
  static Future<void> _loadCountriesIfNeeded() async {
    if (!_box.containsKey('paises')) {
      final response = await http.get(Uri.parse('https://restcountries.com/v3.1/all'));

      if (response.statusCode == 200) {
        await _box.put('paises', response.body); // guarda como JSON string
        print("Países descargados y guardados");
      } else {
        throw Exception("Error cargando países: ${response.statusCode}");
      }
    } else {
      print("Países ya estaban guardados");
    }
  }

  // Método que devuelve el json de los paises
  static List<dynamic> getPaisesJson() {
    final String jsonData = _box.get('paises');
    return json.decode(jsonData);
  }

  // Método para devolver la lista de paises ya con el modelo de Pais.
  static List<Pais> getPaises() {
    final jsonData = _box.get('paises');
    if (jsonData == null) {
      return []; // Revisamos que la lista no es null
    }

    List<Pais> paises = [];
    final List<dynamic> decoded = json.decode(jsonData);
    
    for (final e in decoded) {
      if (e is Map) {
        try {
          paises.add(Pais.fromJson(e));
        } catch (err) {
          print("Error parseando país: $err");
        }
      }
    }

    return paises;
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



  // Guarda el usuario en formato JSON en almacenamiento seguro
  Future<void> saveTeacher(TeacherModel teacher) async {
    print("INSERTING TEACHER");
    final teacherJson = jsonEncode(teacher.toJson());
    print(teacherJson);
    await _prefs.write(key: 'teacherUser', value: teacherJson);
  }

  // Recupera el usuario almacenado
  Future<TeacherModel?> getTeacher() async {
    try {
      final teacherString = await _prefs.read(key: 'teacherUser');
      if (teacherString != null) {
        final userMap = jsonDecode(teacherString);
        return TeacherModel.fromJson(userMap);
      }
    } catch (e) {
      print("Error leyendo el profesor: $e");
    }
    return null;
  }

  Future<void> deleteTeacher() async {
    await _prefs.delete(key: 'teacherUser');
  }

  Future<bool> existTeacher() async {
    final exists = await _prefs.containsKey(key: 'teacherUser');
    return exists;
  }



  Future<void> saveStudent(StudentModel student) async {
    final studentJson = jsonEncode(student.toJson());
    await _prefs.write(key: 'studentUser', value: studentJson);
  }

  // Recupera el usuario almacenado
  Future<StudentModel?> getStudent() async {
    try {
      final studentString = await _prefs.read(key: 'studentUser');
      if (studentString != null) {
        final userMap = jsonDecode(studentString);
        return StudentModel.fromJson(userMap);
      }
    } catch (e) {
      print("Error leyendo el profesor: $e");
    }
    return null;
  }

  Future<void> deleteStudent() async {
    await _prefs.delete(key: 'studentUser');
  }

  Future<bool> existStudent() async {
    final exists = await _prefs.containsKey(key: 'studentUser');
    return exists;
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
