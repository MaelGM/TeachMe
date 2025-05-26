import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:teachme/models/adverstiment_model.dart';
import 'package:teachme/models/enums/AdvertisementState.dart';
import 'package:teachme/models/rating_model.dart';
import 'package:teachme/utils/config.dart';

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
  static List<RatingModel> ratings = [];
  static List<RatingModel> allRatings = [];

  static bool dateOrder = true;
  static bool goodRatingOrder = false;

  static Future<void> setCourse(String id) async {
    try {
      print('COURSE ID: $id');
      final doc = await _firestore.collection('advertisements').doc(id).get();

      course = AdvertisementModel.fromFirestore(doc);
      print(course.description);
      print(course.tutorId);
    } catch (e) {
      throw Exception("Error al obtener el curso: $e");
    }
  }

  Future<void> updateSavedAdvertisementsInFirestore(
    String userId,
    List<AdvertisementModel> savedAds,
  ) async {
    final adsMapList = savedAds.map((ad) => ad.toFirestore()).toList();

    await FirebaseFirestore.instance.collection('students').doc(userId).update({
      'savedAdvertisements': adsMapList,
    });
  }

  Future<List<AdvertisementModel>> getOtherCoursesFromTeacher(
    String teacherId,
  ) async {
    try {
      final snapshot =
          await _firestore
              .collection('advertisements')
              .where('teacherId', isEqualTo: teacherId)
              .limit(6)
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
              .where('specialityId', isEqualTo: specialityId)
              .limit(6)
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
              .where('subjectId', isEqualTo: subjectId)
              .limit(6)
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
    if (!currentStudent.savedAdvertisements.any(
      (ad) => ad.id == CourseService.course.id,
    )) {
      currentStudent.savedAdvertisements.add(CourseService.course);
    }
    currentStudent.payedAdvertisements[price.toString()] = CourseService.course;

    final adsMapList =
        currentStudent.savedAdvertisements
            .map((ad) => ad.toFirestore())
            .toList();
    final payedMap = currentStudent.payedAdvertisements.map(
      (key, ad) => MapEntry(key, ad.toFirestore()),
    );

    await FirebaseFirestore.instance
        .collection('students')
        .doc(currentStudent.userId)
        .update({
          'savedAdvertisements': adsMapList,
          'payedAdvertisements': payedMap,
        });
  }
}
