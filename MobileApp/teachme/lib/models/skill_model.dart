import 'package:cloud_firestore/cloud_firestore.dart';

class Skill {
  final String name;

  Skill({
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }

  // Crear desde JSON
  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      name: json['name'],
    );
  }

  factory Skill.fromFirestore(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>;
  return Skill(
      name: data['name'] ?? '',
    );
  }
}
