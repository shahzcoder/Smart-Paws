import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'vet_models.dart';

class VetService {
  final CollectionReference _appointmentsRef = 
      FirebaseFirestore.instance.collection('appointments');
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  // --- 1. MOCK DATA FOR NEARBY VETS ---
  // In a real app, this would query Firebase based on GPS coordinates.
  List<Vet> getNearbyVets() {
    return [
      // Example coordinates (Change these to coordinates near your actual city!)
      Vet(id: 'v1', name: 'Dr. Sarah Wilson', specialty: 'General Vet & Surgery', address: '123 Main St', distance: 2.4, rating: 4.8, latitude: 31.4221, longitude: 73.0822),
      Vet(id: 'v2', name: 'Paws & Claws Clinic', specialty: 'Vaccination', address: '45 Park Ave', distance: 3.1, rating: 4.5, latitude: 31.4300, longitude: 73.0900),
      Vet(id: 'v3', name: 'Dr. Michael Chen', specialty: 'Emergency Care', address: '88 River Rd', distance: 5.0, rating: 4.9, latitude: 31.4150, longitude: 73.0700),
    ];
  }

  // --- 2. BOOK AN APPOINTMENT ---
  Future<void> bookAppointment(Appointment appointment) async {
    if (_userId == null) return;
    await _appointmentsRef.add(appointment.toJson());
  }

  // --- 3. GET MY APPOINTMENTS (Real-time Stream) ---
  Stream<List<Appointment>> getMyAppointments() {
    if (_userId == null) return const Stream.empty();
    
    return _appointmentsRef
        .where('userId', isEqualTo: _userId)
        .orderBy('dateTime')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Appointment.fromSnapshot(doc)).toList());
  }

  // --- 4. DELETE AN APPOINTMENT (NEWLY ADDED) ---
  Future<void> deleteAppointment(String appointmentId) async {
    try {
      // Find the specific document by its ID and delete it from Firebase
      await _appointmentsRef.doc(appointmentId).delete();
      print("Appointment successfully deleted.");
    } catch (e) {
      print("Error deleting appointment: $e");
      // Throwing an error ensures the 'confirmDismiss' in the UI catches it
      // and stops the swipe if there is no internet connection.
      throw Exception("Failed to delete appointment"); 
    }
  }
}