import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String id;
  final String firstName;
  final String lastName;
  final double cgpa;
  final int? uacePoints;
  final bool isAttachedToHall;
  final bool isGovernmentStudent;
  final bool isDisabled;
  final bool isContinuingResident;
  final bool isPrivateStudent;
  final bool isFresher;
  final String gender;
  String? roomNumber; // Non-final to allow modification
  final String? roomId;

  Student({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.cgpa,
    required this.uacePoints,
    required this.isAttachedToHall,
    required this.isGovernmentStudent,
    required this.isDisabled,
    required this.isContinuingResident,
    required this.isPrivateStudent,
    required this.isFresher,
    required this.gender,
    this.roomNumber,
    this.roomId,
  });

  factory Student.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Handle type conversion carefully
    double cgpa = 0.0;
    if (data['cgpa'] is double) {
      cgpa = data['cgpa'];
    } else if (data['cgpa'] is String) {
      cgpa = double.tryParse(data['cgpa']) ?? 0.0;
    }
    
    int? uacePoints;
    if (data['uacePoints'] is int) {
      uacePoints = data['uacePoints'];
    } else if (data['uacePoints'] is String) {
      uacePoints = int.tryParse(data['uacePoints']);
    }

    return Student(
      id: doc.id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      cgpa: cgpa,
      uacePoints: uacePoints,
      isAttachedToHall: data['isAttachedToHall'] ?? false,
      isGovernmentStudent: data['isGovernmentStudent'] ?? false,
      isDisabled: data['isDisabled'] ?? false,
      isContinuingResident: data['isContinuingResident'] ?? false,
      isPrivateStudent: data['isPrivateStudent'] ?? false,
      isFresher: data['isFresher'] ?? false,
      gender: data['gender'] ?? '',
      roomNumber: data['roomNumber'],
      roomId: data['roomId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'cgpa': cgpa,
      'uacePoints': uacePoints,
      'isAttachedToHall': isAttachedToHall,
      'isGovernmentStudent': isGovernmentStudent,
      'isDisabled': isDisabled,
      'isContinuingResident': isContinuingResident,
      'isPrivateStudent': isPrivateStudent,
      'isFresher': isFresher,
      'gender': gender,
      'roomNumber': roomNumber,
      'roomId': roomId,
    };
  }

  int calculatePoints() {
    int points = 0;
    points += isAttachedToHall ? 10 : 0;
    points += isGovernmentStudent ? 5 : 0;
    points += isDisabled ? 20 : 0;
    points += isContinuingResident ? 15 : 0;
    points += isPrivateStudent ? 5 : 0;
    points += isFresher ? 0 : 10;
    points += cgpa.toInt();
    points += uacePoints ?? 0;
    return points;
  }
}
