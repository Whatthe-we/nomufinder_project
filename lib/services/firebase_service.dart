import 'package:cloud_firestore/cloud_firestore.dart';
import '../viewmodels/input_viewmodel.dart';

class FirebaseService {
  static final _firestore = FirebaseFirestore.instance;

  static Future<void> saveSurvey(InputState state) async {
    try {
      await _firestore.collection('survey_responses').add({
        'gender': state.gender,
        'age': state.age,
        'employment': state.employment,
        'industry': state.industry,
        'companySize': state.companySize,
        'purpose': state.purpose,
        'selectedIssues': state.selectedIssues,
        'infoNeeds': state.infoNeeds,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Firestore 저장 실패: $e');
      rethrow;
    }
  }
}