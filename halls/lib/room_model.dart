import 'package:cloud_firestore/cloud_firestore.dart';

class Room {
  final String id;
  final int roomNumber;
  final int capacity;
  int currentOccupancy;
  String hall;
  String block;
  String level;
  List<String> assignedStudentIds;

  Room({
    required this.id,
    required this.roomNumber,
    required this.capacity,
    required this.currentOccupancy,
    required this.hall,
    required this.block,
    required this.level,
    required this.assignedStudentIds,
  });

  static Room fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Room(
      id: doc.id,
      roomNumber: (data['roomNumber'] as num).toInt(),
      capacity: (data['capacity'] as num).toInt(),
      currentOccupancy: (data['currentOccupancy'] as num).toInt(),
      hall: data['hall'] ?? '',
      block: data['block'] ?? '',
      level: data['level'] ?? '',
      assignedStudentIds: List<String>.from(data['assignedStudentIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roomNumber': roomNumber,
      'capacity': capacity,
      'currentOccupancy': currentOccupancy,
      'hall': hall,
      'block': block,
      'level': level,
      'assignedStudentIds': assignedStudentIds,
    };
  }
}
