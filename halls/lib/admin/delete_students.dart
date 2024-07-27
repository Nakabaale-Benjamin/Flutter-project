import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widget/button.dart';
import "delete_progress.dart";

class FirestoreService {
  final CollectionReference studentsCollection =
      FirebaseFirestore.instance.collection('students');

  Future<void> deleteAllStudents() async {
    try {
      final QuerySnapshot snapshot = await studentsCollection.get();
      for (final DocumentSnapshot doc in snapshot.docs) {
        await doc.reference.delete();
      }
      print('All students deleted successfully.');
    } catch (e) {
      print('Error deleting students: $e');
    }
  }
}

class DeleteAllStudentsButton extends StatelessWidget {
  final FirestoreService firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text(
            "Delete Students",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        body: Column(children: [
          MyButtons(
            onTap: () async {
              await firestoreService.deleteAllStudents();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('All students deleted')),
              );
            },
            text: 'Delete All Students',
          ),
          const SizedBox(
            height: 20,
          ),
          MyButtons(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (BuildContext context) {
                    return ProgressDelete(); // Replace with the actual screen you want to navigate to
                  }),
                );
              },
              text: "Delete Allocation"),

        ]));
  }
}
