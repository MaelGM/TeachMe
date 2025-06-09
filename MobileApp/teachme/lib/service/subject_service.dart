import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:teachme/models/speciality_model.dart';
import 'package:teachme/models/subject_model.dart';
import 'package:teachme/utils/config.dart';
import 'package:teachme/utils/user_preferences.dart';

class SubjectService {
  final CollectionReference _subjectRef = FirebaseFirestore.instance.collection(
    'subjects',
  );
  final CollectionReference _specialityRef = FirebaseFirestore.instance
      .collection('speciality');

  static List<Subject> subjetcs = [];
  static List<Subject> randomSubjects = [];

  Future<List<Subject>> getSubjects() async {
    try {
      final snapshot = await _subjectRef.get();
      subjetcs =
          snapshot.docs.map((doc) => Subject.fromFirestore(doc)).toList();

      return subjetcs;
    } catch (e) {
      throw Exception("Error al obtener asignaturas: $e");
    }
  }

  Future<Subject> getSubjectById(String id) async {
    try {
      final subject = await _subjectRef.doc(id).get();

      return Subject.fromFirestore(subject);
    } catch (e) {
      throw Exception("Error al obtener habilidades: $e");
    }
  }

  Future<List<Subject>> getSubjectsByIds(List<String> ids) async {
    try {
      print('OBTENIENDO SUBJECTS DE IDS');
      if (ids.isEmpty) return [];

      // Consulta cada skill por su ID usando Future.wait para hacer todas las llamadas en paralelo
      final futures = ids.map((id) => _subjectRef.doc(id).get()).toList();

      final snapshots = await Future.wait(futures);

      return snapshots
          .where((doc) => doc.exists)
          .map((doc) => Subject.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception("Error al obtener habilidades: $e");
    }
  }

  Future<List<SpecialityModel>> getSpecialities() async {
    try {
      final snapshot = await _specialityRef.get();
      final specialities =
          snapshot.docs
              .map((doc) => SpecialityModel.fromFirestore(doc))
              .toList();

      return specialities;
    } catch (e) {
      throw Exception("Error al obtener asignaturas: $e");
    }
  }

  Future<List<SpecialityModel>> getSpecialitiesFromSubject(
    String subjectId,
  ) async {
    try {
      final snapshot =
          await _specialityRef.where('subjectId', isEqualTo: subjectId).get();
      final specialities =
          snapshot.docs
              .map((doc) => SpecialityModel.fromFirestore(doc))
              .toList();

      print('GETTING SPECIALITIES ${specialities.length}');
      return specialities;
    } catch (e) {
      throw Exception("Error al obtener asignaturas: $e");
    }
  }

  Future<void> updateStudentInterests(BuildContext context) async {
    try {
      print('ACTUALIZANDO');
      final studentRef = FirebaseFirestore.instance
          .collection('students')
          .doc(currentStudent.userId);

      await studentRef.update({
        'interestsIds': currentStudent.interestsIds,
        'interestsNames': currentStudent.interestsNames,
      });

      UserPreferences.instance.saveStudent(currentStudent);
      Navigator.pop(context, true); // true = indica que hubo cambios
    } catch (e) {
      throw Exception("Error al actualizar intereses del estudiante: $e");
    }
  }

  Future<List<Subject>> getRandomSubjects({required int count}) async {
    try {
      if (randomSubjects.isNotEmpty) return randomSubjects;
      final snapshot = await _subjectRef.get();
      randomSubjects =
          snapshot.docs.map((doc) => Subject.fromFirestore(doc)).toList();

      // Mezclamos aleatoriamente y tomamos "count" elementos
      randomSubjects.shuffle(Random());
      randomSubjects = randomSubjects.take(count).toList();
      return randomSubjects;
    } catch (e) {
      throw Exception("Error al obtener asignaturas aleatorias: $e");
    }
  }

  Future<List<SpecialityModel>> getFeaturedSpecialities({
    required int count,
  }) async {
    try {
      final snapshot = await _specialityRef.get();
      List<SpecialityModel> allSpecialities =
          snapshot.docs
              .map((doc) => SpecialityModel.fromFirestore(doc))
              .toList();

      if (allSpecialities.isEmpty) return [];

      // Mezclamos aleatoriamente y tomamos "count" elementos
      allSpecialities.shuffle(Random());
      return allSpecialities.take(count).toList();
    } catch (e) {
      throw Exception("Error al obtener especialidades destacadas: $e");
    }
  }
}
