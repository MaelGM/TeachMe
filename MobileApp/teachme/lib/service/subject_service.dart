import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:teachme/models/subject_model.dart';
import 'package:teachme/utils/config.dart';

class SubjectService {
  final CollectionReference _subjectRef = FirebaseFirestore.instance.collection(
    'subjects',
  );

  Future<List<Subject>> getSubjects() async {
    try {
      final snapshot = await _subjectRef.get();
      return snapshot.docs.map((doc) => Subject.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception("Error al obtener asignaturas: $e");
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

  Future<void> updateStudentInterests(BuildContext context) async {
  try {
    print('ACTUALIZANDO');
    final studentRef = FirebaseFirestore.instance.collection('students').doc(currentStudent.userId);

    await studentRef.update({
      'interestsIds': currentStudent.interestsIds,
      'interestsNames': currentStudent.interestsNames,
    });
    
    Navigator.pop(context, true); // true = indica que hubo cambios

  } catch (e) {
    throw Exception("Error al actualizar intereses del estudiante: $e");
  }
}

}
