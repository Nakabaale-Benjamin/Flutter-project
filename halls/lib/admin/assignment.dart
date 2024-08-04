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
  Color _statusColor = Colors.black;
  void _assignStudent(String uid) async {
    setState(() {
      _statusMessage = 'Assigning students...';
      _statusColor = Colors.blue;
    });

    try {
      await _firestoreService.processAllStudents();
      setState(() {
        _statusMessage = 'Students assigned successfully!';
        _statusColor = Colors.green;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error assigning student: ${e.toString()}';
        _statusColor = Colors.red;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Assign Rooms',style: TextStyle(
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
                _assignStudent('student_uid_here');
              },
              text: 'Assign Students'),
            const SizedBox(height: 20),
            Text(
              _statusMessage,
              style:  TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _statusColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
