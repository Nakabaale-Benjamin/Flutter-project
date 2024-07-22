// room_allocation_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_model.dart';

class StudentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> maleHalls = ['Nkrumah', 'Livingstone', 'Michell', 'Nsibirwa', 'University Hall', 'Lumumba'];
  final List<String> femaleHalls = ['Africa', 'Mary Stuart', 'Complex'];
  int maleHallIndex = 0;
  int femaleHallIndex = 0;

  Future<List<Student>> fetchStudents() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('students').get();
      List<Student> students = querySnapshot.docs.map((doc) {
        return Student.fromFirestore(doc);
      }).toList();
      print('Fetched ${students.length} students');
      return students;
    } catch (e) {
      print('Error fetching students: $e');
      return [];
    }
  }

  Future<void> allocateRooms(List<Student> students) async {
    try {
      students.sort((a, b) => b.calculatePoints().compareTo(a.calculatePoints()));
      Map<String, List<Student>> studentsByHall = {};
      for (var student in students) {
        String hallName = student.gender == 'male' ? getMaleHall() : getFemaleHall();
        if (!studentsByHall.containsKey(hallName)) {
          studentsByHall[hallName] = [];
        }
        studentsByHall[hallName]!.add(student);
      }
      for (var hallName in studentsByHall.keys) {
        List<Student> hallStudents = studentsByHall[hallName]!;
        QuerySnapshot roomQuery = await _firestore.collection('rooms').where('hall', isEqualTo: hallName).orderBy('roomNumber').get();
        int roomIndex = 0;
        for (var student in hallStudents) {
          if (roomIndex >= roomQuery.docs.length) {
            print('No more available rooms in hall $hallName for ${student.firstName} ${student.lastName}');
            break;
          }
          DocumentSnapshot roomDoc = roomQuery.docs[roomIndex];
          String roomId = roomDoc.id;
          await _firestore.collection('rooms').doc(roomId).update({
            'currentOccupancy': FieldValue.increment(1),
            'assignedStudentIds': FieldValue.arrayUnion([student.id]),
          });
          await _firestore.collection('students').doc(student.id).update({
            'roomNumber': roomDoc['roomNumber'],
          });
          print('Assigned student ${student.firstName} ${student.lastName} to room ${roomDoc['roomNumber']} in hall $hallName');
          roomIndex++;
        }
      }
    } catch (e) {
      print('Error allocating rooms: $e');
    }
  }

  String getMaleHall() {
    if (maleHallIndex >= maleHalls.length) {
      maleHallIndex = 0;
    }
    return maleHalls[maleHallIndex++];
  }

  String getFemaleHall() {
    if (femaleHallIndex >= femaleHalls.length) {
      femaleHallIndex = 0;
    }
    return femaleHalls[femaleHallIndex++];
  }
}
