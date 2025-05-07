import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_nomufinder/models/lawyer.dart';

class FirebaseLawyerService {
  static final _firestore = FirebaseFirestore.instance;

  static Future<List<Lawyer>> fetchLawyers() async {
    final snapshot = await _firestore.collection('lawyers').get();

    // 🔄 문서 ID와 데이터 둘 다 전달
    return snapshot.docs.map((doc) {
      return Lawyer.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }).toList();
  }
}
