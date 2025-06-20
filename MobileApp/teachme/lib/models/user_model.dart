import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String id;
  String connected;
  String email;
  bool isStudent;
  bool isTeacher;
  String username;
  String profilePicture;

  // Constructor
  UserModel({
    required this.id,
    required this.connected,
    required this.email,
    required this.isStudent,
    required this.isTeacher,
    required this.username,
    required this.profilePicture,
  });

  // Método para crear un UserModel desde un documento de Firestore (DocumentSnapshot)
  factory UserModel.fromDocument(DocumentSnapshot doc) {
    return UserModel(
      id: doc.id,
      connected: doc['conected'] ?? false,
      email: doc['email'] ?? '',
      isStudent: doc['isStudent'] ?? false,
      isTeacher: doc['isTeacher'] ?? false,
      username: doc['username'] ?? '',
      profilePicture: doc['profile_picture'] ?? '',
    );
  }

  // Método para crear un UserModel desde un JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      connected: json['conected'] ?? false,
      email: json['email'] ?? '',
      isStudent: json['isStudent'] ?? false,
      isTeacher: json['isTeacher'] ?? false,
      username: json['username'] ?? '',
      profilePicture: json['profile_picture'] ?? '',
    );
  }

  // Método para convertir el UserModel a un Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conected': connected,
      'email': email,
      'isStudent': isStudent,
      'isTeacher': isTeacher,
      'username': username,
      'profile_picture': profilePicture,
    };
  }

  // Método para convertir el UserModel a un Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'conected': connected,
      'email': email,
      'isStudent': isStudent,
      'isTeacher': isTeacher,
      'username': username,
      'profile_picture': profilePicture,
    };
  }
}
