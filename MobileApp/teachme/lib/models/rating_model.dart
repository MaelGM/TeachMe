import 'package:cloud_firestore/cloud_firestore.dart';

class RatingModel {
  String id;
  String userId;
  String userName;
  String userPhotoUrl;
  String? teacherId;
  String? advertisementId;
  String comment;
  DateTime date;
  double score;
  List<String> photos;

  RatingModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhotoUrl,
    this.teacherId,
    this.advertisementId,
    required this.comment,
    required this.date,
    required this.score,
    required this.photos
  });

  // Crear desde Firestore
  factory RatingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RatingModel(
      id: doc.id,
      advertisementId: data['advertisementId'],
      teacherId: data['teacherId'],
      userId: data['userId'],
      userName: data['userName'],
      userPhotoUrl: data['userPhotoUrl'],
      score: (data['score'] as num).toDouble(),
      comment: data['comment'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      photos: List<String>.from(data['photos'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'advertisementId': advertisementId,
      'teacherId': teacherId,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'score': score,
      'comment': comment,
      'date': Timestamp.fromDate(date),
    };
  }

}