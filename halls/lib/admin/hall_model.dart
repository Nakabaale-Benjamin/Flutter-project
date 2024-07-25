import "package:cloud_firestore/cloud_firestore.dart";
class Halls{
  String id;
  int bedspace;
  int rooms;

  Halls({required this.id, required this.bedspace, required this.rooms});

  factory Halls.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Halls(
      id: doc.id,
      bedspace: data['bedspace'] as int,
      rooms: data['rooms'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bedspace': bedspace,
      'rooms': rooms,
    };
  }
}
