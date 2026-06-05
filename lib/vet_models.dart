import 'package:cloud_firestore/cloud_firestore.dart';

// 1. The Vet Model (Data for the clinics)
class Vet {
  final String id;
  final String name;
  final String specialty;
  final String address;
  final double distance; // in km
  final double rating;
  final double latitude;
  final double longitude;

  Vet({
    required this.id, required this.name, required this.specialty,
    required this.address, required this.distance, required this.rating,
    required this.latitude, required this.longitude,
  });
}

// 2. The Appointment Model (Data saved to Firebase)
class Appointment {
  final String id;
  final String userId;
  final String vetId;
  final String vetName;
  final String appointmentType; // "Home Visit" or "Clinic"
  final DateTime dateTime;
  final String status; // "Upcoming", "Completed", "Vet is on the way"
  final String notes;

  Appointment({
    required this.id, required this.userId, required this.vetId,
    required this.vetName, required this.appointmentType,
    required this.dateTime, required this.status, required this.notes,
  });

  factory Appointment.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Appointment(
      id: doc.id,
      userId: data['userId'] ?? '',
      vetId: data['vetId'] ?? '',
      vetName: data['vetName'] ?? '',
      appointmentType: data['appointmentType'] ?? 'Clinic',
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      status: data['status'] ?? 'Upcoming',
      notes: data['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'vetId': vetId,
      'vetName': vetName,
      'appointmentType': appointmentType,
      'dateTime': dateTime,
      'status': status,
      'notes': notes,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}