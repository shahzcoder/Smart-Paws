import 'package:cloud_firestore/cloud_firestore.dart';

class VaccineRecord {
  final String id;
  final String userId;
  final String petName;
  final String vaccineName;
  final DateTime dateAdministered;
  final DateTime nextDueDate;
  final String veterinarian;
  final String notes;

  VaccineRecord({
    required this.id,
    required this.userId,
    required this.petName,
    required this.vaccineName,
    required this.dateAdministered,
    required this.nextDueDate,
    required this.veterinarian,
    required this.notes,
  });

  factory VaccineRecord.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // --- DEBUGGING PRINTS ---
    print("Reading Document: ${doc.id}");
    print(" - Pet Name in DB: '${data['petName']}'");
    print(" - Vaccine in DB: '${data['vaccineName']}'");
    // ------------------------

    return VaccineRecord(
      id: doc.id,
      userId: data['userId'] ?? '',
      // Ensure these keys match your Firestore Screenshot exactly!
      petName: data['petName'] ?? '',       
      vaccineName: data['vaccineName'] ?? '',
      dateAdministered: (data['dateAdministered'] as Timestamp).toDate(),
      nextDueDate: (data['nextDueDate'] as Timestamp).toDate(),
      veterinarian: data['veterinarian'] ?? '',
      notes: data['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'petName': petName,
      'vaccineName': vaccineName,
      'dateAdministered': dateAdministered,
      'nextDueDate': nextDueDate,
      'veterinarian': veterinarian,
      'notes': notes,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}