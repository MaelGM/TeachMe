import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:teachme/models/adverstiment_model.dart';
import 'package:teachme/models/enums/AdvertisementState.dart';
import 'package:teachme/models/rating_model.dart';
import 'package:teachme/models/teacher_model.dart';
import 'package:teachme/models/user_model.dart';
import 'package:teachme/utils/config.dart';
import 'package:teachme/utils/user_preferences.dart';

class CourseService extends ChangeNotifier {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static AdvertisementModel course = AdvertisementModel(
    id: '',
    title: '',
    parametersBasic: {},
    description: '',
    photos: [],
    prices: [],
    publicationDate: DateTime.now(),
    score: 0,
    scoreCount: 0,
    state: AdvertisementState.hidden,
    specialityId: '',
    tutorId: '',
    subjectId: '',
  );
  static TeacherModel author = TeacherModel(
    userId: '',
    aboutMe: '',
    birthDate: '',
    rating: 0,
    ratingCount: 0,
    country: '',
    timeZone: '',
    memberSince: '',
    skills: [],
  );
  static UserModel authorUserAcount = UserModel(
    id: '',
    connected: '',
    email: '',
    isStudent: false,
    isTeacher: false,
    username: '',
    profilePicture: '',
  );
  static const String cloudName = 'dkxcnf3jm';
  static const String uploadPreset = 'teachMe';
  static List<RatingModel> ratings = [];
  static List<RatingModel> allRatings = [];

  static bool dateOrder = true;
  static bool goodRatingOrder = false;

  static Map<String, dynamic> filters = {
    'subjectId': null,
    'specialityIds': [],
    'order': 'date',
  };

  static Future<void> setTeacher(String id) async {
    try {
      final doc = await _firestore.collection('teachers').doc(id).get();
      dateOrder = true;
      goodRatingOrder = false;

      author = TeacherModel.fromFirestore(doc);
      await setUserAcount(id);
    } catch (e) {
      throw Exception("Error al obtener al profesor: $e");
    }
  }

  static Future<void> setUserAcount(String id) async {
    try {
      final doc = await _firestore.collection('users').doc(id).get();

      authorUserAcount = UserModel.fromDocument(doc);
    } catch (e) {
      throw Exception("Error al obtener al profesor: $e");
    }
  }

  static Future<void> setCourse(String id) async {
    try {
      print('COURSE ID: $id');
      final doc = await _firestore.collection('advertisements').doc(id).get();

      course = AdvertisementModel.fromFirestore(doc);
    } catch (e) {
      throw Exception("Error al obtener el curso: $e");
    }
  }

  Future<void> updateSavedAdvertisementsInFirestore(
    String userId,
    List<String> savedAds,
  ) async {
    currentStudent.savedAdvertisements = savedAds;
    await UserPreferences.instance.saveStudent(currentStudent);

    await FirebaseFirestore.instance.collection('students').doc(userId).update({
      'savedAdvertisements': currentStudent.savedAdvertisements,
    });
  }

  Future<List<AdvertisementModel>> getOtherCoursesFromTeacher(
    String teacherId,
  ) async {
    try {
      final snapshot =
          await _firestore
              .collection('advertisements')
              .where('state', isEqualTo: 'active')
              .where('teacherId', isEqualTo: teacherId)
              .limit(5)
              .get();

      final otherCourse =
          snapshot.docs
              .map((doc) => AdvertisementModel.fromFirestore(doc))
              //.where((courseItem) => courseItem.id != course.id)
              .toList();

      return otherCourse;
    } catch (e) {
      throw Exception("Error al obtener los cursos: $e");
    }
  }

  Future<List<AdvertisementModel>> getOtherCoursesFromSpeciality(
    String specialityId,
  ) async {
    try {
      final snapshot =
          await _firestore
              .collection('advertisements')
              .where('state', isEqualTo: 'active')
              .where('specialityId', isEqualTo: specialityId)
              .limit(5)
              .get();

      final otherCourse =
          snapshot.docs
              .map((doc) => AdvertisementModel.fromFirestore(doc))
              //.where((courseItem) => courseItem.id != course.id)
              .toList();

      return otherCourse;
    } catch (e) {
      throw Exception("Error al obtener los cursos: $e");
    }
  }

  Future<List<AdvertisementModel>> getOtherCoursesFromSubject(
    String subjectId,
  ) async {
    try {
      final snapshot =
          await _firestore
              .collection('advertisements')
              .where('state', isEqualTo: 'active')
              .where('subjectId', isEqualTo: subjectId)
              .limit(5)
              .get();

      final otherCourse =
          snapshot.docs
              .map((doc) => AdvertisementModel.fromFirestore(doc))
              //.where((courseItem) => courseItem.id != course.id)
              .toList();

      return otherCourse;
    } catch (e) {
      throw Exception("Error al obtener los cursos: $e");
    }
  }

  // Obtenemos los primeros comentarios de un curso en concreto ordenado
  Future<void> getFirstsComments() async {
    try {
      print(course.id);
      final snapshot =
          await _firestore
              .collection('ratings')
              .where('advertisementId', isEqualTo: course.id)
              .limit(6)
              .get();

      ratings =
          snapshot.docs.map((doc) => RatingModel.fromFirestore(doc)).toList();
      notifyListeners();
    } catch (e) {
      throw Exception("Error al obtener los comentarios: $e");
    }
  }

  Future<void> getCommentsByRating(bool descending) async {
    try {
      print(course.id);
      final snapshot =
          await _firestore
              .collection('ratings')
              .where('advertisementId', isEqualTo: course.id)
              .orderBy('score', descending: descending)
              .get();

      dateOrder = false;
      goodRatingOrder = descending;

      allRatings =
          snapshot.docs.map((doc) => RatingModel.fromFirestore(doc)).toList();
      notifyListeners();
    } catch (e) {
      throw Exception("Error al obtener los comentarios: $e");
    }
  }

  Future<void> getCommentsByDate() async {
    try {
      print(course.id);
      final snapshot =
          await _firestore
              .collection('ratings')
              .where('advertisementId', isEqualTo: course.id)
              .orderBy('date', descending: true)
              .get();

      dateOrder = true;
      goodRatingOrder = false;

      allRatings =
          snapshot.docs.map((doc) => RatingModel.fromFirestore(doc)).toList();
      notifyListeners();
    } catch (e) {
      throw Exception("Error al obtener los comentarios: $e");
    }
  }

  static Future<void> payCourse(double price) async {
    // Añadir a favoritos si no está ya
    if (!currentStudent.savedAdvertisements.contains(CourseService.course.id)) {
      currentStudent.savedAdvertisements.add(CourseService.course.id);
    }

    final currentPaid =
        currentStudent.payedAdvertisements[CourseService.course.id];

    // Si no existe el pago o es menor al nuevo precio, se actualiza
    if (currentPaid == null || currentPaid < price) {
      currentStudent.payedAdvertisements[CourseService.course.id] = price;
    }

    await FirebaseFirestore.instance
        .collection('students')
        .doc(currentStudent.userId)
        .update({
          'savedAdvertisements': currentStudent.savedAdvertisements,
          'payedAdvertisements': currentStudent.payedAdvertisements,
        });

    await UserPreferences.instance.saveStudent(currentStudent);
  }

  Future<List<AdvertisementModel>> searchCourses({String? title}) async {
    try {
      filters.forEach((key, value) {
        print('Clave: $key, Valor: $value');
      });

      Query query = _firestore
          .collection('advertisements')
          .where('state', isEqualTo: 'active');

      if (filters['subjectId'] != null) {
        query = query.where('subjectId', isEqualTo: filters['subjectId']);
      }
      if (filters['specialityIds'] != null &&
          (filters['specialityIds'] as List).isNotEmpty) {
        query = query.where('specialityId', whereIn: filters['specialityIds']);
      }

      String order = filters['order'] ?? 'date';

      switch (order) {
        case 'date':
          query = query.orderBy('publicationDate', descending: true);
          break;
        case 'date2':
          query = query.orderBy('publicationDate', descending: false);
          break;
        case 'scoreCount':
          query = query.orderBy('scoreCount', descending: true);
          break;
        case 'score':
          query = query.orderBy('score', descending: true);
          break;
        case 'score2':
          query = query.orderBy('score', descending: false);
          break;
        case 'title':
          query = query.orderBy('title', descending: false);
          break;
        default:
          query = query.orderBy('publicationDate', descending: true);
          break;
      }

      final snapshot = await query.get();
      final searchLower = title?.toLowerCase();

      final filteredCourses =
          snapshot.docs
              .map((doc) => AdvertisementModel.fromFirestore(doc))
              .where((course) {
                // Validar título (containsIgnoreCase)
                if (searchLower != null && searchLower.isNotEmpty) {
                  final courseTitle = course.title.toLowerCase();
                  if (!courseTitle.contains(searchLower)) return false;
                }

                return true;
              })
              .toList();

      return filteredCourses;
    } catch (e) {
      throw Exception('Error al buscar cursos: $e');
    }
  }

  Future<List<AdvertisementModel>> getPopularCourses({
    required int count,
  }) async {
    try {
      final snapshot =
          await _firestore
              .collection('advertisements')
              .where('state', isEqualTo: 'active')
              .orderBy('score', descending: true)
              .orderBy('countScore', descending: true)
              .limit(count)
              .get();

      return snapshot.docs
          .map((doc) => AdvertisementModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception("Error al obtener cursos populares: $e");
    }
  }

  static Future<List<String>> uploadImagesToCloudinary(List<File> files) async {
    List<String> uploadedUrls = [];

    for (File file in files) {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );
      final request =
          http.MultipartRequest('POST', uri)
            ..fields['upload_preset'] = uploadPreset
            ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final resStr = await response.stream.bytesToString();
        final data = json.decode(resStr);
        uploadedUrls.add(data['secure_url']);
      } else {
        print(
          'Cloudinary upload failed for ${file.path}: ${response.statusCode}',
        );
      }
    }

    return uploadedUrls;
  }

  static Future<void> postComment(RatingModel comentario) async {
    await _firestore.collection('ratings').add({
      'userId': comentario.userId,
      'userName': comentario.userName,
      'userPhotoUrl': comentario.userPhotoUrl,
      'comment': comentario.comment,
      'date': comentario.date,
      'score': comentario.score,
      'photos': comentario.photos,
      'advertisementId': comentario.advertisementId,
    });

    await updateCourseScore(comentario.advertisementId!);
  }

  static Future<void> updateCourseScore(String courseId) async {
    final ratingsSnapshot =
        await _firestore
            .collection('ratings')
            .where('advertisementId', isEqualTo: courseId)
            .get();

    if (ratingsSnapshot.docs.isEmpty) {
      print('No hay puntuaciones para este curso.');
      return;
    }

    double totalScore = 0;
    int scoreCount = 0;

    for (var doc in ratingsSnapshot.docs) {
      final data = doc.data();
      if (data.containsKey('score')) {
        totalScore += (data['score'] as num).toDouble();
        scoreCount++;
      }
    }

    final averageScore = totalScore / scoreCount;

    await _firestore.collection('advertisements').doc(courseId).update({
      'score': averageScore,
      'scoreCount': scoreCount,
    });

    print('Curso actualizado con promedio: $averageScore ($scoreCount votos)');
  }

  static Future<void> changeState(String state, String courseId) async {
    await _firestore.collection('advertisements').doc(courseId).update({
      'state': state,
    });
  }

  static Future<AdvertisementModel?> getCourseById(String courseId) async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('advertisements')
              .doc(courseId)
              .get();

      if (!doc.exists) return null;

      return AdvertisementModel.fromFirestore(doc);
    } catch (e) {
      print('Error al obtener el curso: $e');
      return null;
    }
  }

  
}
