import 'package:cloud_firestore/cloud_firestore.dart';

class StudentModel {
  String userId;
  List<String> interestsIds;
  List<String> interestsNames;
  List<String> savedAdvertisements;
  Map<String, double> payedAdvertisements; // Cambiado aquí

  StudentModel({
    required this.userId,
    required this.interestsIds,
    required this.interestsNames,
    required this.savedAdvertisements,
    required this.payedAdvertisements,
  });

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'interestsIds': interestsIds,
      'interestsNames': interestsNames,
      'savedAdvertisements': savedAdvertisements,
      'payedAdvertisements': payedAdvertisements,
    };
  }

  // Crear desde JSON
  factory StudentModel.fromJson(Map<String, dynamic> json) {
    final rawMap = Map<String, dynamic>.from(json['payedAdvertisements'] ?? {});
    final parsedMap = rawMap.map((key, value) => MapEntry(key, (value as num).toDouble()));

    return StudentModel(
      userId: json['userId'],
      interestsIds: List<String>.from(json['interestsIds'] ?? []),
      interestsNames: List<String>.from(json['interestsNames'] ?? []),
      savedAdvertisements: List<String>.from(json['savedAdvertisements'] ?? []),
      payedAdvertisements: parsedMap,
    );
  }

  // Crear desde Firestore
  factory StudentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final rawMap = Map<String, dynamic>.from(data['payedAdvertisements'] ?? {});
    final parsedMap = rawMap.map((key, value) => MapEntry(key, (value as num).toDouble()));

    return StudentModel(
      userId: data['userId'],
      interestsIds: List<String>.from(data['interestsIds'] ?? []),
      interestsNames: List<String>.from(data['interestsNames'] ?? []),
      savedAdvertisements: List<String>.from(data['savedAdvertisements'] ?? []),
      payedAdvertisements: parsedMap,
    );
  }
}
