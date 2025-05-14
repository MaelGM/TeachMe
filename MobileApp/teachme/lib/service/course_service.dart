import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:teachme/models/adverstiment_model.dart';
import 'package:teachme/models/enums/AdvertisementState.dart';
import 'package:teachme/models/rating_model.dart';

class CourseService extends ChangeNotifier{
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static AdvertisementModel course = AdvertisementModel(id: '',title: '', parametersBasic: {}, description: '', photos: [], prices: [], publicationDate: DateTime.now(), score: 0, scoreCount: 0, state: AdvertisementState.hidden, specialityId: '', tutorId: '');
  static List<RatingModel> ratings = []; 

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

  // Obtenemos los primeros comentarios de un curso en concreto ordenado
  Future<void> getFirstsComments() async {
    try {
      print(course.id);
      final snapshot = await _firestore.collection('ratings').where('advertisementId', isEqualTo: course.id).limit(6).get();

      ratings = snapshot.docs.map((doc) => RatingModel.fromFirestore(doc)).toList();
      notifyListeners();
    } catch (e) {
      throw Exception("Error al obtener los comentarios: $e");
    }
  }

  // Obtenemos todos los comentarios de un curso en concreto ordenado
  Future<void> getComments() async {
    try {
      print(course.id);
      final snapshot = await _firestore.collection('ratings').where('advertisementId', isEqualTo: course.id).get();

      ratings = snapshot.docs.map((doc) => RatingModel.fromFirestore(doc)).toList();
      notifyListeners();
    } catch (e) {
      throw Exception("Error al obtener los comentarios: $e");
    }
  }
}
