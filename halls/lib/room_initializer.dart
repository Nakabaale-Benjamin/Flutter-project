import 'package:cloud_firestore/cloud_firestore.dart';

class RoomInitializer {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to initialize 180 rooms for a specific hall
  Future<void> initializeRooms(String hallId) async {
    try {
      CollectionReference roomsCollection = _firestore.collection('rooms');
      
      for (int i = 1; i <= 180; i++) {
        await roomsCollection.add({
          'roomNumber': i,
          'capacity': 3,
          'currentOccupancy': 0,
          'hall': hallId,
          
          'assignedStudentIds': [], // List of student IDs assigned to the room
        });
      }
      print('Initialized 180 rooms for hall $hallId');
    } catch (e) {
      print('Error initializing rooms: $e');
    }
  }
}
