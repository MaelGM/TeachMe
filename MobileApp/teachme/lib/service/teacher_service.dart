import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:teachme/models/adverstiment_model.dart';
import 'package:teachme/models/models.dart';
import 'package:teachme/models/rating_model.dart';
import 'package:teachme/models/teacher_model.dart';
import 'package:teachme/utils/config.dart';

class TeacherService extends ChangeNotifier{
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static List<RatingModel> ratings = [];
  static List<AdvertisementModel> courses = [];
  static TeacherModel teacher = TeacherModel(userId: '', aboutMe: '', birthDate: '', rating: 0, ratingCount: 0, country: '', timeZone: '', memberSince: '', skills: []);
  static UserModel teacherUserAcount = UserModel(id: '', connected: '', email: '', isStudent: false, isTeacher: false, username: '', profilePicture: '');

  static bool dateOrder = true;
  static bool goodRatingOrder = false;


  static Future<void> setTeacher(String id) async {
    try {
      
      print('TEACHER ID: $id');
      final doc = await _firestore.collection('teachers').doc(id).get();
      dateOrder = true;
      goodRatingOrder = false;

      teacher = TeacherModel.fromFirestore(doc);
      await setUserAcount(id);
    } catch (e) {
      throw Exception("Error al obtener al profesor: $e");
    }
  }

  static Future<void> setUserAcount(String id) async {
    try {
      print('USER ID: $id');

      final doc = await _firestore.collection('users').doc(id).get();

      teacherUserAcount = UserModel.fromDocument(doc);
    } catch (e) {
      throw Exception("Error al obtener al profesor: $e");
    }
  }

  // Obtenemos todos los comentarios de un profesor en concreto ordenado segun la fecha
  Future<void> getCoursesFromTeacher(String id) async {
    try {
      final snapshot = await _firestore.collection('advertisements').where('teacherId', isEqualTo: id).get();

      courses = snapshot.docs.map((doc) => AdvertisementModel.fromFirestore(doc)).toList();
      notifyListeners();
    } catch (e) {
      throw Exception("Error al obtener los cursos: $e");
    }
  }

  // Obtenemos todos los comentarios de un profesor en concreto ordenado segun la fecha
  Future<void> getCommentsByDate(DocumentSnapshot? lastDoc) async {
    try {
      final snapshot = await _firestore.collection('ratings').where('teacherId', isEqualTo: teacher.userId).orderBy('date', descending: true).get();

      dateOrder = true;
      goodRatingOrder = false;

      ratings = snapshot.docs.map((doc) => RatingModel.fromFirestore(doc)).toList();
      notifyListeners();
    } catch (e) {
      throw Exception("Error al obtener los comentarios: $e");
    }
  }

  // Obtenemos todos los comentarios de un profesor en concreto ordenado segun la nota de manera ascendente
  Future<void> getCommentsByScoreAscending(DocumentSnapshot? lastDoc) async {
    try {
      final snapshot = await _firestore.collection('ratings').where('teacherId', isEqualTo: teacher.userId).orderBy('score', descending: false).get();

      dateOrder = false;
      goodRatingOrder = false;

      ratings = snapshot.docs.map((doc) => RatingModel.fromFirestore(doc)).toList();
      notifyListeners();
    } catch (e) {
      throw Exception("Error al obtener los comentarios: $e");
    }
  }

  // Obtenemos todos los comentarios de un profesor en concreto ordenado segun la nota de manera descendente
  Future<void> getCommentsByScoreDescending(DocumentSnapshot? lastDoc) async {
    try {
      final snapshot = await _firestore.collection('ratings').where('teacherId', isEqualTo: teacher.userId).orderBy('score', descending: true).get();

      dateOrder = false;
      goodRatingOrder = true;

      ratings = snapshot.docs.map((doc) => RatingModel.fromFirestore(doc)).toList();
      notifyListeners();
    } catch (e) {
      throw Exception("Error al obtener los comentarios: $e");
    }
  }

  // Añadir un comentario al profesor
  Future<void> addRatingToTeacher({
    required String teacherId,
    required double score,
    required String comment,
    List<String>? photos
  }) async {
    final ratingsRef = _firestore.collection('ratings');

    final newRating = RatingModel(
      id: '',
      teacherId: teacherId,
      advertisementId: null,
      userId: currentUser.id,
      userName: currentUser.username,
      userPhotoUrl: currentUser.profilePicture,
      score: score,
      comment: comment,
      date: DateTime.now(),
      photos: photos ?? []
    );

    await ratingsRef.add(newRating.toMap());
    

    // Actualizamos la media del profesor
    await updateTeacherRatingStats(teacherId: teacherId, score: score);
  }

  // Actualizamos el contador de comentario, y con ello, la nota media 
  Future<void> updateTeacherRatingStats({
    required String teacherId,
    required double score,
  }) async {
    final teacher = _firestore.collection('teachers').doc(teacherId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(teacher);

      final currentCount = snapshot.data()?['ratingCount'] ?? 0;
      final currentAverage = snapshot.data()?['rating']?.toDouble() ?? 0.0;

      final newCount = currentCount + 1;
      final newAverage = ((currentAverage * currentCount) + score) / newCount;

      transaction.update(teacher, {
        'ratingCount': newCount,
        'rating': newAverage,
      });
    });
  }
}
