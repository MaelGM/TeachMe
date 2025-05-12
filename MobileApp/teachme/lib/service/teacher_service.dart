import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teachme/models/rating_model.dart';
import 'package:teachme/utils/config.dart';

class TeacherService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtenemos todos los comentarios de un profesor en concreto
  Future<List<RatingModel>> getComments(String teacherId, String scoreOrder, DocumentSnapshot? lastDoc) async {
    try {
      Query query = await _firestore.collection('ratings').where('teacherId', isEqualTo: teacherId);

      if (scoreOrder == 'date') {
        query = query.orderBy('date', descending: true);
      } else if (scoreOrder == 'ascending') {
        query = query.orderBy('score', descending: false);
      } else if (scoreOrder == 'descending') {
        query = query.orderBy('score', descending: true);
      }
      
      final snapshot = await query.get();

      return snapshot.docs.map((doc) => RatingModel.fromFirestore(doc)).toList();
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
