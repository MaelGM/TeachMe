import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:teachme/models/adverstiment_model.dart';

class StudentService extends ChangeNotifier {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<AdvertisementModel> _favorites = [];

  List<AdvertisementModel> get favorites => _favorites;

  Future<void> fetchFavorites(String userId) async {
    try {
      final doc = await _firestore.collection('students').doc(userId).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['savedAdvertisements'] != null) {
          // savedAdvertisements es una lista de mapas
          final savedAdsData = List<Map<String, dynamic>>.from(data['savedAdvertisements']);
          _favorites = savedAdsData.map((adData) => AdvertisementModel.fromJson(adData)).toList();
        } else {
          _favorites = [];
        }
      } else {
        _favorites = [];
      }
      notifyListeners();
    } catch (e) {
      print('Error fetching favorites: $e');
      _favorites = [];
      notifyListeners();
    }
  }
}
