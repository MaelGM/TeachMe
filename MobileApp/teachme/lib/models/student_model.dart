import 'package:cloud_firestore/cloud_firestore.dart';

class StudentModel {
  String userId;
  List<String> interestsIds;
  List<String> interestsNames;
<<<<<<< Updated upstream
=======
  List<AdvertisementModel> savedAdvertisements;
  List<AdvertisementModel> payedAdvertisements; // NUEVO CAMPO
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes

  StudentModel({
    required this.userId,
    required this.interestsIds,
    required this.interestsNames,
  });

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'interestsIds': interestsIds,
      'interestsNames': interestsNames,
<<<<<<< Updated upstream
=======
      'savedAdvertisements':
          savedAdvertisements.map((ad) => ad.toFirestore()).toList(),
      'payedAdvertisements': payedAdvertisements.map((ad) => ad.toFirestore()).toList(),
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
    };
  }

  // Crear desde JSON
  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      userId: json['userId'],
<<<<<<< Updated upstream
      interestsIds: List<String>.from(json['interestsIds']),
      interestsNames: List<String>.from(json['interestsNames']),
=======
      interestsIds: List<String>.from(json['interestsIds'] ?? []),
      interestsNames: List<String>.from(json['interestsNames'] ?? []),
      savedAdvertisements:
          (json['savedAdvertisements'] as List<dynamic>? ?? [])
              .map((item) => AdvertisementModel.fromJson(item))
              .toList(),
      payedAdvertisements:
          (json['payedAdvertisements'] as List<dynamic>? ?? [])
              .map((item) => AdvertisementModel.fromJson(item))
              .toList(),
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
    );
  }

  factory StudentModel.fromFirestore(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>;
  return StudentModel(
      userId: data['userId'] ?? '',
      interestsIds: List<String>.from(data['interestsIds'] ?? []),
      interestsNames: List<String>.from(data['interestsNames'] ?? []),
<<<<<<< Updated upstream
=======
      savedAdvertisements:
          (data['savedAdvertisements'] as List<dynamic>? ?? [])
              .map((item) => AdvertisementModel.fromJson(item))
              .toList(),
      payedAdvertisements:
          (data['payedAdvertisements'] as List<dynamic>? ?? [])
              .map((item) => AdvertisementModel.fromJson(item))
              .toList(),
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
    );
  }

}
