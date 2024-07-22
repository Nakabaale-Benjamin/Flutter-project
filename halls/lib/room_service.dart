import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_model.dart';

class RoomService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> assignRoomToStudent(Student student, String hallName) async {
    try {
      CollectionReference roomsCollection = _firestore.collection('rooms');
      
      // Find the first room in the specified hall that has available space
      QuerySnapshot querySnapshot = await roomsCollection
        .where('hall', isEqualTo: hallName)
        .where('currentOccupancy', isLessThan: 3)
        .limit(1)
        .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot roomDoc = querySnapshot.docs.first;
        Map<String, dynamic> roomData = roomDoc.data() as Map<String, dynamic>;

        // Update room data
        roomData['currentOccupancy'] += 1;
        roomData['assignedStudentIds'].add(student.id);

        // Update room in Firestore
        await roomsCollection.doc(roomDoc.id).update(roomData);

        // Update student with room number
        student.roomNumber = roomData['roomNumber'];
        await _firestore.collection('students').doc(student.id).update({
          'roomNumber': student.roomNumber,
        });

        print('Assigned room ${student.roomNumber} to student ${student.firstName} ${student.lastName}');
      } else {
        print('No available rooms for hall $hallName');
      }
    } catch (e) {
      print('Error assigning room to student: $e');
    }
  }
}
