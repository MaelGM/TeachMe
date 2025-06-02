import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
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

    currentStudent.savedAdvertisements = savedAds;
    await UserPreferences.instance.saveStudent(currentStudent);

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

    // Crear una copia del anuncio con el precio pagado
    final paidAd = AdvertisementModel(
      id: CourseService.course.id,
      title: CourseService.course.title,
      parametersBasic: CourseService.course.parametersBasic,
      parametersPro: CourseService.course.parametersPro,
      parametersDeluxe: CourseService.course.parametersDeluxe,
      description: CourseService.course.description,
      photos: CourseService.course.photos,
      prices: CourseService.course.prices,
      publicationDate: CourseService.course.publicationDate,
      score: CourseService.course.score,
      scoreCount: CourseService.course.scoreCount,
      state: CourseService.course.state,
      specialityId: CourseService.course.specialityId,
      subjectId: CourseService.course.subjectId,
      tutorId: CourseService.course.tutorId,
      paidPrice: price, // 🆕 Aquí guardamos solo el precio pagado
    );

    currentStudent.payedAdvertisements.add(paidAd);

    final adsMapList =
        currentStudent.savedAdvertisements
            .map((ad) => ad.toFirestore())
            .toList();
    final payedList =
        currentStudent.payedAdvertisements
            .map((ad) => ad.toFirestore())
            .toList();

    await FirebaseFirestore.instance
        .collection('students')
        .doc(currentStudent.userId)
        .update({
          'savedAdvertisements': adsMapList,
          'payedAdvertisements': payedList,
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
          .where('state', isEqualTo: 'Active');

      // Puedes eliminar el filtro inicial por título y hacerlo en el filtrado local
      // Esto permite búsqueda "containsIgnoreCase"
      // Si quieres dejarlo, puedes mantenerlo (aunque es menos flexible)

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
}
