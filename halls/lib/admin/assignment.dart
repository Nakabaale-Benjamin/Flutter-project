import 'package:flutter/material.dart';
import 'firestore_service.dart'; // Import the FirestoreService

class StudentAssignmentScreen extends StatefulWidget {
  const StudentAssignmentScreen({super.key});

  @override
  _StudentAssignmentScreenState createState() => _StudentAssignmentScreenState();
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
        title: const Text('Student Assignment'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                // Replace with the UID of the student you want to assign
                _assignStudent('student_uid_here');
              },
              child: const Text('Assign Student'),
            ),
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
