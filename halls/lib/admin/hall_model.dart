import 'package:cloud_firestore/cloud_firestore.dart';

class Hall {
  final String id;
  final int bedspace;
  final int rooms;

  Hall({required this.id, required this.bedspace, required this.rooms});

  factory Hall.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Hall(
      id: doc.id,
      bedspace: data['bedspace'] ?? 0,
      rooms: data['rooms'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bedspace': bedspace,
      'rooms': rooms,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Hall &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
