import 'package:cloud_firestore/cloud_firestore.dart';


class Student {
  String id;
  String? firstName;
  String? lastName;
  String? gender;
  String? hall;
  int? roomNumber; // Change to int
  String? roomId;
  bool isGovernmentStudent;
  bool isDisabled;
  bool isContinuingResident;
  bool isPrivateStudent;
  bool isFresher;
  bool isAttachedToHall;
  int cgpa;
  int? uacePoints;

  Student({
    required this.id,
    this.firstName,
    this.lastName,
    this.gender,
    this.hall,
    this.roomNumber, // Change to int
    this.roomId,
    required this.isGovernmentStudent,
    required this.isDisabled,
    required this.isContinuingResident,
    required this.isPrivateStudent,
    required this.isFresher,
    required this.isAttachedToHall,
    required this.cgpa,
    this.uacePoints,
  });

  factory Student.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;

    return Student(
      id: doc.id,
      firstName: data['firstName'] as String? ?? '',
      lastName: data['lastName'] as String? ?? '',
      gender: data['gender'] as String? ?? '',
      hall: data['hall'] as String? ?? '',
      roomNumber: data['roomNumber'] is int ? data['roomNumber'] : int.tryParse(data['roomNumber'].toString()), // Ensure roomNumber is an int
      roomId: data['roomId'] as String?,
      isGovernmentStudent: data['isGovernmentStudent'] as bool? ?? false,
      isDisabled: data['isDisabled'] as bool? ?? false,
      isContinuingResident: data['isContinuingResident'] as bool? ?? false,
      isPrivateStudent: data['isPrivateStudent'] as bool? ?? false,
      isFresher: data['isFresher'] as bool? ?? false,
      isAttachedToHall: data['isAttachedToHall'] as bool? ?? false,
      cgpa: data['cgpa'] as int? ?? 0,
      uacePoints: data['uacePoints'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'hall': hall,
      'roomNumber': roomNumber,
      'roomId': roomId,
      'isGovernmentStudent': isGovernmentStudent,
      'isDisabled': isDisabled,
      'isContinuingResident': isContinuingResident,
      'isPrivateStudent': isPrivateStudent,
      'isFresher': isFresher,
      'isAttachedToHall': isAttachedToHall,
      'cgpa': cgpa,
      'uacePoints': uacePoints,
    };
  }

  int calculatePoints() {
    int points = 0;
    points += cgpa;
    points += uacePoints ?? 0;
    if (isGovernmentStudent) points += 10;
    if (isDisabled) points += 10;
    if (isContinuingResident) points += 5;
    if (isPrivateStudent) points -= 5;
    if (isFresher) points -= 5;

    return points;
  }
}