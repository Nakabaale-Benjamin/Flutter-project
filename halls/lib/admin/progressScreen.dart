import 'package:flutter/material.dart';
import 'firestore_service.dart';

class StudentProgressScreen extends StatefulWidget {
  const StudentProgressScreen({super.key});

  @override
  _StudentProgressScreenState createState() => _StudentProgressScreenState();
}

class _StudentProgressScreenState extends State<StudentProgressScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> _progressList = [];

  @override
  void initState() {
    super.initState();
    _fetchProgressData();
  }

  Future<void> _fetchProgressData() async {
    final progressList = await _firestoreService.fetchAllProgress();
    setState(() {
      _progressList = progressList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Progress'),
      ),
      body: ListView.builder(
        itemCount: _progressList.length,
        itemBuilder: (context, index) {
          final progress = _progressList[index];
          return ListTile(
            title: Text('${progress['name']}'),
            subtitle: Text(
              'Registration Number: ${progress['registrationNumber']}\n'
              'Hall: ${progress['hall']}\n'
              'Bedspace: ${progress['bedspace']}\n'
              'Points: ${progress['points']}',
            ),
            onTap: () {
              // You can choose to handle tap events here if needed
            },
          );
        },
      ),
    );
  }
}
