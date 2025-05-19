import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:teachme/utils/utils.dart';

class Subject {
  final String id;
  final String name;
  final String description;
  final String iconName;

  Subject({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
  });

  factory Subject.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Subject(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      iconName: data['icon'] ?? 'book', // valor por defecto
    );
  }

  IconData get icon => iconSubjectsMap[iconName] ?? Icons.book;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Subject && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
