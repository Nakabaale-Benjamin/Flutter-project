
import 'package:flutter/material.dart';
import 'firestore_service.dart';

class AdminStudentListScreen extends StatefulWidget {
  const AdminStudentListScreen({super.key});

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
    final students = await _firestoreService.fetchAllStudents();
    setState(() {
      _students = students;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student List'),
      ),
      body: ListView.builder(
        itemCount: _students.length,
        itemBuilder: (context, index) {
          final student = _students[index];
          return ListTile(
            title: Text('${index + 1}. ${student['fullName']}'),
            subtitle: Text('ID: ${student['id']}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentDetailScreen(studentId: student['fullName']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class StudentDetailScreen extends StatelessWidget {
  final String studentId;

  const StudentDetailScreen({required this.studentId, super.key});

  Future<Map<String, dynamic>> _fetchStudentDetail(String id) async {
    final firestoreService = FirestoreService();
    return await firestoreService.fetchStudentDetails(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Detail'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchStudentDetail(studentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final student = snapshot.data;

          if (student == null) {
            return const Center(child: Text('No student data found.'));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Name: ${student['fullName']}',),
                Text('ID: ${student['id']}'),
                Text('Email: ${student['email']}'),
                Text('CGPA: ${student['cgpa']}'),
                Text('Year of Study: ${student['yearOfStudy']}'),
                Text('College: ${student['college']}'),
                Text('Student Type: ${student['studentType']}'),
                Text('Hall of Attachment: ${student['hallOfAttachment']}'),
                Text('Has Disability: ${student['hasDisability']}'),
                Text('Continuing Resident: ${student['isContinuingResident']}'),
                // Add more fields as necessary
              ],
            ),
          );
        },
      ),
    );
  }
}