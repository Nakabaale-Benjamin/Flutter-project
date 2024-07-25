import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_model.dart'; // Ensure this is the path to your Student model

class StudentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> maleHalls = ['Nkrumah', 'Livingstone', 'Michell', 'Nsibirwa', 'University Hall', 'Lumumba'];
  final List<String> femaleHalls = ['Africa', 'Mary Stuart', 'Complex'];
  int maleHallIndex = 0;
  int femaleHallIndex = 0;

  // Function to determine the hall for a male student
  String getMaleHall() {
    if (maleHallIndex >= maleHalls.length) {
      maleHallIndex = 0; // Reset index if it exceeds the list length
    }
    return maleHalls[maleHallIndex++];
  }

  // Function to determine the hall for a female student
  String getFemaleHall() {
    if (femaleHallIndex >= femaleHalls.length) {
      femaleHallIndex = 0; // Reset index if it exceeds the list length
    }
    return femaleHalls[femaleHallIndex++];
  }

  // Function to fetch all students
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

  // Function to fetch assigned students (students with non-null room numbers)
  Future<List<Student>> fetchAssignedStudents() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('students').where('roomNumber', isNotEqualTo: null).get();
      
      List<Student> students = querySnapshot.docs.map((doc) {
        return Student.fromFirestore(doc);
      }).toList();

      print('Fetched ${students.length} assigned students');
      return students;
    } catch (e) {
      print('Error fetching assigned students: $e');
      return [];
    }
  }

  // Function to allocate rooms based on criteria
  Future<void> allocateRooms() async {
    try {
      List<Student> students = await fetchStudents();
      
      // Sort students by criteria (e.g., points)
      students.sort((a, b) => b.calculatePoints().compareTo(a.calculatePoints()));

      // Group students by hall
      Map<String, List<Student>> studentsByHall = {};
      for (var student in students) {
        String hallName = student.gender == 'male' ? getMaleHall() : getFemaleHall();
        if (!studentsByHall.containsKey(hallName)) {
          studentsByHall[hallName] = [];
        }
        studentsByHall[hallName]!.add(student);
      }

      // Allocate rooms sequentially within each hall
      for (var hallName in studentsByHall.keys) {
        List<Student> hallStudents = studentsByHall[hallName]!;

        // Fetch available rooms for this hall in order
        QuerySnapshot roomQuery = await _firestore
            .collection('rooms')
            .where('hall', isEqualTo: hallName)
            .orderBy('roomNumber') // Ensure rooms are allocated sequentially
            .get();
        
        int roomIndex = 0;
        for (var student in hallStudents) {
          if (roomIndex >= roomQuery.docs.length) {
            print('No more available rooms in hall $hallName for ${student.firstName} ${student.lastName}');
            break;
          }

          DocumentSnapshot roomDoc = roomQuery.docs[roomIndex];
          String roomId = roomDoc.id;

          // Update the room's current occupancy and assigned students
          await _firestore.collection('rooms').doc(roomId).update({
            'currentOccupancy': FieldValue.increment(1),
            'assignedStudentIds': FieldValue.arrayUnion([student.id]),
          });

          // Update the student's roomNumber
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
}