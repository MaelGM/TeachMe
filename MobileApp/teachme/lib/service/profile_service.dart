import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teachme/providers/edit_form_provider.dart';

import '../utils/config.dart'; // Asumiendo que `currentUser` está aquí

class ProfileService {
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
