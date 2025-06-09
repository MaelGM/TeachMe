import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teachme/models/enums/AdvertisementState.dart';

class AdvertisementModel {
  final String id;
  String title;
  Map<String, String>? parametersDeluxe;
  Map<String, String>? parametersPro;
  Map<String, String> parametersBasic;
  String description;
  final List<String> photos;
  List<double> prices;
  final DateTime publicationDate;
  final double score;
  final double scoreCount;
  AdvertisementState state;
  String specialityId;
  String subjectId;
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
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      if(parametersDeluxe != null) 'parametersDeluxe': parametersDeluxe,
      if(parametersPro != null) 'parametersPro': parametersPro,
      'parametersBasic': parametersBasic,
      'description': description,
      'photos': photos,
      'prices': prices,
      'publicationDate': publicationDate,
      'score': score,
      'scoreCount': scoreCount,
      'state': state.name,
      'specialityId': specialityId,
      'subjectId': subjectId,
      'teacherId': tutorId,
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
      tutorId: json['teacherId'] ?? '',
    );
  }
}
