import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teachme/models/adverstiment_model.dart';

class StudentModel {
  String userId;
  List<String> interestsIds;
  List<String> interestsNames;
  List<AdvertisementModel> savedAdvertisements;
  Map<String, AdvertisementModel> payedAdvertisements; // NUEVO CAMPO

  StudentModel({
    required this.userId,
    required this.interestsIds,
    required this.interestsNames,
    required this.savedAdvertisements,
    required this.payedAdvertisements, // Añadido al constructor
  });

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'interestsIds': interestsIds,
      'interestsNames': interestsNames,
      'savedAdvertisements':
          savedAdvertisements.map((ad) => ad.toFirestore()).toList(),
      'payedAdvertisements': payedAdvertisements.map(
        (key, ad) => MapEntry(key, ad.toFirestore()),
      ),
    };
  }

  // Crear desde JSON
  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      userId: json['userId'],
      interestsIds: List<String>.from(json['interestsIds'] ?? []),
      interestsNames: List<String>.from(json['interestsNames'] ?? []),
      savedAdvertisements:
          (json['savedAdvertisements'] as List<dynamic>? ?? [])
              .map((item) => AdvertisementModel.fromJson(item))
              .toList(),
      payedAdvertisements:
          (json['payedAdvertisements'] as Map<String, dynamic>? ?? {}).map(
            (key, value) => MapEntry(key, AdvertisementModel.fromJson(value)),
          ),
    );
  }

  // Crear desde Firestore
  factory StudentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StudentModel(
      userId: data['userId'],
      interestsIds: List<String>.from(data['interestsIds'] ?? []),
      interestsNames: List<String>.from(data['interestsNames'] ?? []),
      savedAdvertisements:
          (data['savedAdvertisements'] as List<dynamic>? ?? [])
              .map((item) => AdvertisementModel.fromJson(item))
              .toList(),
      payedAdvertisements:
          (data['payedAdvertisements'] as Map<String, dynamic>? ?? {}).map(
            (key, value) => MapEntry(key, AdvertisementModel.fromJson(value)),
          ),
    );
  }
}
