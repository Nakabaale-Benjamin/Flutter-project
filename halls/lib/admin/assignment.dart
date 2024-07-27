import 'package:flutter/material.dart';
import 'firestore_service.dart'; // Import the FirestoreService
import "../widget/button.dart";

class StudentAssignmentScreen extends StatefulWidget {
  const StudentAssignmentScreen({super.key});

  @override
  _StudentAssignmentScreenState createState() =>
      _StudentAssignmentScreenState();
}

class _StudentAssignmentScreenState extends State<StudentAssignmentScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _statusMessage = '';

  void _assignStudent(String uid) async {
    setState(() {
      _statusMessage = 'Assigning student...';
    });

    try {
      await _firestoreService.processAllStudents();
      setState(() {
        _statusMessage = 'Student assigned successfully!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error assigning student: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Student Assignment To Rooms',style: TextStyle(
                    fontSize: 25
                    ,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            MyButtons(
              onTap: () {
                // Replace with the UID of the student you want to assign
                _assignStudent('student_uid_here');
              },
              text: 'Assign Students'),
            const SizedBox(height: 20),
            Text(
              _statusMessage,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
