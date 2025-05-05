import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teachme/models/subject_model.dart';

class SubjectService {
  final CollectionReference _subjectRef = FirebaseFirestore.instance.collection('subjects');

  Future<List<Subject>> getSubjects() async {
    try {
      final snapshot = await _subjectRef.get();
      return snapshot.docs.map((doc) => Subject.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception("Error al obtener asignaturas: $e");
    }
  }
}
