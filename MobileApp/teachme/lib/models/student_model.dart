import 'package:cloud_firestore/cloud_firestore.dart';

class StudentModel {
  String userId;
  List<String> interestsIds;
  List<String> interestsNames;

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
    };
  }

  // Crear desde JSON
  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      userId: json['userId'],
      interestsIds: List<String>.from(json['interestsIds']),
      interestsNames: List<String>.from(json['interestsNames']),
    );
  }

  factory StudentModel.fromFirestore(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>;
  return StudentModel(
      userId: data['userId'] ?? '',
      interestsIds: List<String>.from(data['interestsIds'] ?? []),
      interestsNames: List<String>.from(data['interestsNames'] ?? []),
    );
  }

}
