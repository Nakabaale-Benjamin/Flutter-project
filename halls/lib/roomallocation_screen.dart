import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_model.dart'; // Ensure Student model is imported and defined correctly

class RoomAllocationScreen extends StatefulWidget {
  @override
  _RoomAllocationScreenState createState() => _RoomAllocationScreenState();
}

class _RoomAllocationScreenState extends State<RoomAllocationScreen> {
  Future<List<Student>> fetchStudents() async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    try {
      QuerySnapshot querySnapshot = await _firestore.collection('students').get();
      List<Student> students = querySnapshot.docs.map((doc) {
        return Student.fromFirestore(doc);
      }).toList();

      return students;
    } catch (e) {
      print('Error fetching students: $e');
      return [];
    }
  }

  Future<void> allocateRooms(List<Student> students) async {
    try {
      // Sort students by their total points in descending order
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

        // Fetch available rooms for this hall
        QuerySnapshot roomQuery = await FirebaseFirestore.instance
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
          String roomNumber = roomDoc['roomNumber'];

          // Update the room's current occupancy and assigned students
          await FirebaseFirestore.instance.collection('rooms').doc(roomId).update({
            'currentOccupancy': FieldValue.increment(1),
            'assignedStudentIds': FieldValue.arrayUnion([student.id]),
          });

          // Update the student's roomNumber
          await FirebaseFirestore.instance.collection('students').doc(student.id).update({
            'roomNumber': roomNumber,
          });

          student.roomNumber = roomNumber; // Update local state

          print('Assigned student ${student.firstName} ${student.lastName} to room $roomNumber in hall $hallName');

          roomIndex++;
        }
      }
    } catch (e) {
      print('Error allocating rooms: $e');
    }
  }

  String getMaleHall() {
    // Logic to determine and return a male hall
    // Replace this with your actual implementation
    return 'Nkrumah'; // Example
  }

  String getFemaleHall() {
    // Logic to determine and return a female hall
    // Replace this with your actual implementation
    return 'Africa'; // Example
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Room Allocation'),
      ),
      body: FutureBuilder<List<Student>>(
        future: fetchStudents(), // Fetch students from Firestore
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          List<Student> students = snapshot.data ?? [];

          // Allocate rooms based on criteria
          allocateRooms(students);

          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('${students[index].firstName} ${students[index].lastName}'),
                subtitle: Text('Room: ${students[index].roomNumber ?? "Not allocated"}'),
              );
            },
          );
        },
      ),
    );
  }
}
