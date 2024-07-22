import 'package:flutter/material.dart';
import 'student_service.dart'; // Import the StudentService
import 'student_model.dart'; // Import the Student model

class AssignedStudentsScreen extends StatefulWidget {
  @override
  _AssignedStudentsScreenState createState() => _AssignedStudentsScreenState();
}

class _AssignedStudentsScreenState extends State<AssignedStudentsScreen> {
  late Future<List<Student>> _assignedStudents;

  @override
  void initState() {
    super.initState();
    _assignedStudents = StudentService().fetchAssignedStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assigned Students'),
      ),
      body: FutureBuilder<List<Student>>(
        future: _assignedStudents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No students have been assigned rooms.'));
          } else {
            List<Student> students = snapshot.data!;

            return ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                Student student = students[index];
                return ListTile(
                  title: Text('${student.firstName} ${student.lastName}'),
                  subtitle: Text('Room Number: ${student.roomNumber ?? 'Not Assigned'}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
