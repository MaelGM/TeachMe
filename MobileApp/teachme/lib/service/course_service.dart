import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:teachme/models/adverstiment_model.dart';
import 'package:teachme/models/enums/AdvertisementState.dart';

class CourseService extends ChangeNotifier{
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static AdvertisementModel course = AdvertisementModel(title: '', parametersBasic: {}, description: '', photos: [], prices: [], publicationDate: DateTime.now(), score: 0, scoreCount: 0, state: AdvertisementState.hidden, specialityId: '', tutorId: ''); 

}
