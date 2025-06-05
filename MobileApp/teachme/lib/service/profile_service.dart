import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teachme/providers/edit_form_provider.dart';

import '../utils/config.dart'; // Asumiendo que `currentUser` está aquí

class ProfileService {
  static const String cloudName = 'dkxcnf3jm';
  static const String uploadPreset = 'teachMe';

  /// Sube la imagen a Cloudinary y devuelve la URL segura
  static Future<String?> uploadImageToCloudinary(File file) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );
    final request =
        http.MultipartRequest('POST', uri)
          ..fields['upload_preset'] = uploadPreset
          ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final resStr = await response.stream.bytesToString();
      final data = json.decode(resStr);
      return data['secure_url'];
    } else {
      print('Cloudinary upload failed: ${response.statusCode}');
      return null;
    }
  }

  static Future<void> updateUser(
    EditFormProvider editForm,
    String imageUrl,
    BuildContext context,
  ) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'profile_picture': imageUrl,
      'username': editForm.name,
      // solo actualizar el email si ya fue confirmado
      if (editForm.email == FirebaseAuth.instance.currentUser!.email)
        'email': editForm.email,
    });

    currentUser.profilePicture = imageUrl;
    currentUser.username = editForm.name;

    // solo actualizar el email local si ya fue verificado
    if (editForm.email == FirebaseAuth.instance.currentUser!.email) {
      currentUser.email = editForm.email;
    }
  }
}
