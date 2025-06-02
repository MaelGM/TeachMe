import 'package:cloud_firestore/cloud_firestore.dart';

class SpecialityModel {
  final String id;
  final String name;
  final String description;
  final String subjectId;

  SpecialityModel({
    required this.id,
    required this.name,
    required this.description,
    required this.subjectId,
  });

  factory SpecialityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SpecialityModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      subjectId: data['subjectId'] ?? '',
    );
  }
}
