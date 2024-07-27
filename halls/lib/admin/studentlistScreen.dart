import 'package:flutter/material.dart';
import 'firestore_service.dart';

class AdminStudentListScreen extends StatefulWidget {
  const AdminStudentListScreen({Key? key}) : super(key: key);

  @override
  _AdminStudentListScreenState createState() => _AdminStudentListScreenState();
}

class _AdminStudentListScreenState extends State<AdminStudentListScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> _students = [];

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
  }

  Future<void> _fetchStudentData() async {
    try {
      final students = await _firestoreService.fetchAllStudents();
      setState(() {
        _students = students;
      });
    } catch (e) {
      print('Error fetching student data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Student List', style: TextStyle(
          fontWeight: FontWeight.bold,
         fontSize:30.0,
         color: Colors.white,
        ))),
      body: SingleChildScrollView(
        child: Column(
          children: _students.map((student) {
            return Column(
              children: [
                Text('Name: ${student['fullName'] ?? 'N/A'}'),
                Text('Email: ${student['email'] ?? 'N/A'}'),
                Text('CGPA: ${student['cgpa']?.toString() ?? 'N/A'}'),
                Text('Year of Study: ${student['yearOfStudy'] ?? 'N/A'}'),
                Text('College: ${student['college'] ?? 'N/A'}'),
                Text('Student Type: ${student['studentType'] ?? 'N/A'}'),
                Text('Hall of Attachment: ${student['hallOfAttachment'] ?? 'N/A'}'),
                Text('Has Disability: ${student['hasDisability'] ?? 'N/A'}'),
                Text('Continuing Resident: ${student['isContinuingResident'] ?? 'N/A'}'),
                const SizedBox(
                  height: 35,)

              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
