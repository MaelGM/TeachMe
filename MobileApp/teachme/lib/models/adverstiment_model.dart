import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teachme/models/enums/AdvertisementState.dart';

class AdvertisementModel {
  final String id;
  final String title;
  final Map<String, String>? parametersDeluxe;
  final Map<String, String>? parametersPro;
  final Map<String, String> parametersBasic;
  final String description;
  final List<String> photos;
  final List<double> prices;
  final DateTime publicationDate;
  final double score;
  final double scoreCount;
  final AdvertisementState state;
  final String specialityId;
  final String tutorId;

  AdvertisementModel({
    required this.id,
    required this.title,
    required this.parametersBasic,
    required this.description,
    required this.photos,
    required this.prices,
    required this.publicationDate,
    required this.score,
    required this.scoreCount,
    required this.state,
    required this.specialityId,
    required this.tutorId,
    this.parametersDeluxe,
    this.parametersPro,
  });

  // Convertir desde Firestore
  factory AdvertisementModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return AdvertisementModel(
      id: doc.id,
      title: data['title'],
      parametersDeluxe: Map<String, String>.from(data['parametersDeluxe'] ?? {}),
      parametersPro: Map<String, String>.from(data['parametersPro'] ?? {}),
      parametersBasic: Map<String, String>.from(data['parametersBasic']),
      description: data['description'],
      photos: List<String>.from(data['photos']),
      prices: List<double>.from(data['prices'].map((e) => e.toDouble())),
      publicationDate: (data['publicationDate'] as Timestamp).toDate(),
      score: (data['score'] ?? 0).toDouble(),
      scoreCount: (data['scoreCount'] ?? 0).toDouble(),
      state: AdvertisementStateExtension.fromString(data['state']),
      specialityId: data['specialityId'],
      tutorId: data['teacherId'],
    );
  }

  // Convertir a Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'parametersDeluxe': parametersDeluxe,
      'parametersPro': parametersPro,
      'parametersBasic': parametersBasic,
      'description': description,
      'photos': photos,
      'prices': prices,
      'publicationDate': publicationDate,
      'score': score,
      'scoreCount': scoreCount,
      'state': state.name,
      'specialityId': specialityId,
      'tutorId': tutorId,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'parametersDeluxe': parametersDeluxe,
      'parametersPro': parametersPro,
      'parametersBasic': parametersBasic,
      'description': description,
      'photos': photos,
      'prices': prices,
      'publicationDate': publicationDate.toIso8601String(),
      'score': score,
      'scoreCount': scoreCount,
      'state': state.name,
      'specialityId': specialityId,
      'tutorId': tutorId,
    };
  }

}
