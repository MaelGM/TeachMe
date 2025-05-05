import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherModel {
  String userId;
  String aboutMe;
  String country;
  String timeZone;
  String birthDate;
  String memberSince;
  double rating;

  TeacherModel({
    required this.userId,
    required this.aboutMe,
    required this.country,
    required this.timeZone,
    required this.memberSince,
    required this.birthDate,
    required this.rating,
  });

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'aboutMe': aboutMe,
      'country': country,
      'timeZone': timeZone,
      'memberSince': memberSince,
      'birthDate': birthDate,
      'rating': rating,
    };
  }

  // Crear desde JSON
  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      userId: json['userId'] ?? '',
      aboutMe: json['aboutMe'] ?? '',
      country: json['country'] ?? '',
      timeZone: json['timeZone'] ?? '',
      memberSince: json['memberSince'] ?? '',
      birthDate: json['birthDate'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
    );
  }

  // Crear desde Firestore
  factory TeacherModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TeacherModel(
      userId: data['userId'] ?? '',
      aboutMe: data['aboutMe'] ?? '',
      country: data['country'] ?? '',
      timeZone: data['timeZone'] ?? '',
      memberSince: data['memberSince'] ?? '',
      birthDate: data['birthDate'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
    );
  }
}
