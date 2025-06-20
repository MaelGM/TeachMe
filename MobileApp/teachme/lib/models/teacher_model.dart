import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherModel {
  String userId;
  String aboutMe;
  String country;
  String timeZone;
  String birthDate;
  String memberSince;
  List<String> skills;
  double rating;
  int ratingCount;

  TeacherModel({
    required this.userId,
    required this.aboutMe,
    required this.country,
    required this.timeZone,
    required this.memberSince,
    required this.birthDate,
    required this.skills,
    required this.rating,
    required this.ratingCount,
  });

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'aboutMe': aboutMe,
      'countryName': country,
      'timeZone': timeZone,
      'memberSince': memberSince,
      'birthDate': birthDate,
      'skills': skills,
      'rating': rating,
      'ratingCount': ratingCount,
    };
  }

  // Crear desde JSON
  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      userId: json['userId'] ?? '',
      aboutMe: json['aboutMe'] ?? '',
      country: json['countryName'] ?? '',
      timeZone: json['timeZone'] ?? '',
      memberSince: json['memberSince'] ?? '',
      birthDate: json['birthDate'] ?? '',
      skills: List<String>.from(json['skills'] ?? []),
      rating: (json['rating'] ?? 0).toDouble(),
      ratingCount: (json['ratingCount'] ?? 0),
    );
  }

  // Crear desde Firestore
  factory TeacherModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TeacherModel(
      userId: data['userId'] ?? '',
      aboutMe: data['aboutMe'] ?? '',
      country: data['countryName'] ?? '',
      timeZone: data['timeZone'] ?? '',
      memberSince: data['memberSince'] ?? '',
      birthDate: data['birthDate'] ?? '',
      skills: List<String>.from(data['skills'] ?? []),
      rating: (data['rating'] ?? 0).toDouble(),
      ratingCount: (data['ratingCount'] ?? 0),
    );
  }
}
