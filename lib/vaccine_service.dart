import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'vaccine_model.dart';

class VaccineService {
  final CollectionReference _vaccineCollection = 
      FirebaseFirestore.instance.collection('vaccinations');
  
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  // 1. ADD Record
  Future<void> addRecord(VaccineRecord record) async {
    if (_userId == null) return;
    await _vaccineCollection.add(record.toJson());
  }

  // 2. UPDATE Record
  Future<void> updateRecord(String docId, VaccineRecord record) async {
    await _vaccineCollection.doc(docId).update(record.toJson());
  }

  // 3. DELETE Record
  Future<void> deleteRecord(String docId) async {
    await _vaccineCollection.doc(docId).delete();
  }

  // 4. GET Stream (Real-time List)
  Stream<List<VaccineRecord>> getVaccines() {
    if (_userId == null) return const Stream.empty();
    
    return _vaccineCollection
        .where('userId', isEqualTo: _userId) // Only get current user's data
        .orderBy('nextDueDate') // Sort by upcoming dates
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => VaccineRecord.fromSnapshot(doc)).toList();
        });
  }
}