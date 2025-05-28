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
  final String subjectId;
  final String tutorId;
  final double? paidPrice;

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
    required this.subjectId,
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
      parametersDeluxe: Map<String, String>.from(
        data['parametersDeluxe'] ?? {},
      ),
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
      subjectId: data['subjectId'],
      tutorId: data['teacherId'],
      paidPrice: (data['paidPrice'] ?? 0).toDouble(),
    );
  }

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
      'publicationDate': publicationDate.toIso8601String(),
      'score': score,
      'scoreCount': scoreCount,
      'state': state.name,
      'specialityId': specialityId,
      'subjectId': subjectId,
      'tutorId': tutorId,
      'paidPrice': paidPrice,
    };
  }

  factory AdvertisementModel.fromJson(Map<String, dynamic> json) {
    return AdvertisementModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      parametersDeluxe:
          json['parametersDeluxe'] != null
              ? Map<String, String>.from(json['parametersDeluxe'])
              : null,
      parametersPro:
          json['parametersPro'] != null
              ? Map<String, String>.from(json['parametersPro'])
              : null,
      parametersBasic: Map<String, String>.from(json['parametersBasic'] ?? {}),
      description: json['description'] ?? '',
      photos:
          json['photos'] != null
              ? List<String>.from(json['photos'])
              : <String>[],
      prices:
          json['prices'] != null
              ? List<double>.from(json['prices'].map((e) => e.toDouble()))
              : <double>[],
      publicationDate:
          json['publicationDate'] is Timestamp
              ? (json['publicationDate'] as Timestamp).toDate()
              : DateTime.tryParse(json['publicationDate'] ?? '') ??
                  DateTime.now(),

      score: (json['score'] ?? 0).toDouble(),
      scoreCount: (json['scoreCount'] ?? 0).toDouble(),
      state: AdvertisementStateExtension.fromString(json['state']),
      specialityId: json['specialityId'] ?? '',
      subjectId: json['subjectId'] ?? '',
      tutorId: json['tutorId'] ?? '',
      paidPrice: (json['paidPrice'] ?? 0).toDouble(),
    );
  }
}
