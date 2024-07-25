import 'package:cloud_firestore/cloud_firestore.dart';

class Criteria {
  final int attachmentToHall;
  final int governmentStudent;
  final int disabled;
  final int cgpa;
  final int continuingResident;
  final int privateStudent;

  // Dynamically calculated field
  int get totalPoints => attachmentToHall +
      governmentStudent +
      disabled +
      cgpa +
      continuingResident +
      privateStudent;

  Criteria({
    required this.attachmentToHall,
    required this.governmentStudent,
    required this.disabled,
    required this.cgpa,
    required this.continuingResident,
    required this.privateStudent,
  });

  factory Criteria.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Criteria(
      attachmentToHall: data['attachmentToHall'] ?? 0,
      governmentStudent: data['governmentStudent'] ?? 0,
      disabled: data['disabled'] ?? 0,
      cgpa: data['cgpa'] ?? 0,
      continuingResident: data['continuingResident'] ?? 0,
      privateStudent: data['privateStudent'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'attachmentToHall': attachmentToHall,
      'governmentStudent': governmentStudent,
      'disabled': disabled,
      'cgpa': cgpa,
      'continuingResident': continuingResident,
      'privateStudent': privateStudent,
      // Do not include totalPoints here as it's calculated dynamically
    };
  }
}
