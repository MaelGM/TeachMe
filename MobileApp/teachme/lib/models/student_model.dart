import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teachme/models/adverstiment_model.dart';

class StudentModel {
  String userId;
  List<String> interestsIds;
  List<String> interestsNames;
  List<AdvertisementModel> savedAdvertisements;

  StudentModel({
    required this.userId,
    required this.interestsIds,
    required this.interestsNames,
    required this.savedAdvertisements,
  });

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'interestsIds': interestsIds,
      'interestsNames': interestsNames,
      'savedAdvertisements': savedAdvertisements.map((ad) => ad.toFirestore()).toList(),
    };
  }

  // Crear desde JSON
  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      userId: json['userId'],
      interestsIds: List<String>.from(json['interestsIds'] ?? []),
      interestsNames: List<String>.from(json['interestsNames'] ?? []),
      savedAdvertisements: (json['savedAdvertisements'] as List<dynamic>? ?? [])
          .map((item) => AdvertisementModel.fromJson(item))
          .toList(),
    );
  }

  // Crear desde Firestore
  factory StudentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StudentModel(
      userId: data['userId'] ?? '',
      interestsIds: List<String>.from(data['interestsIds'] ?? []),
      interestsNames: List<String>.from(data['interestsNames'] ?? []),
      savedAdvertisements: (data['savedAdvertisements'] as List<dynamic>? ?? [])
          .map((item) => AdvertisementModel.fromJson(item))
          .toList(),
    );
  }
}
