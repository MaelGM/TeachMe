import 'package:cloud_firestore/cloud_firestore.dart';

class SkillService {
  final CollectionReference _skillCollection =
      FirebaseFirestore.instance.collection('skills');

  /// Obtener todas las habilidades como lista de strings
  Future<List<String>> getAllSkills() async {
    final snapshot = await _skillCollection.get();
    return snapshot.docs
        .map((doc) => (doc.data() as Map<String, dynamic>)['name'] as String)
        .toList();
  }

  Future<bool> skillExists(String habilidad) async {
    final query = await _skillCollection
        .where('name', isEqualTo: habilidad.trim())
        .limit(1)
        .get();

    print(habilidad);

    if(query.docs.isEmpty) {
      print("ERROR: La habilidad ${habilidad} no existe.");
      
      return false;
    } else {
      return true;
    }
  }
}
