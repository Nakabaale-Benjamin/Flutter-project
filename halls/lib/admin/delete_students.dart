import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widget/button.dart';

class FirestoreService {
  final CollectionReference studentsCollection =
      FirebaseFirestore.instance.collection('students');
  final CollectionReference progressCollection =
      FirebaseFirestore.instance.collection('progress');
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

  Future<void> deleteAll() async {
    try {
      final QuerySnapshot snapshot = await progressCollection.get();
      for (final DocumentSnapshot doc in snapshot.docs) {
        await doc.reference.delete();
      }
      print('Allocation deleted');
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
            "Delete Students information",
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
                SnackBar(content: Text('All students deleted', style: TextStyle(fontSize: 25.0),),
                backgroundColor: Colors.blue,),
              );
            },
            text: 'Delete Applied Students',
          ),
          const SizedBox(
            height: 20,
          ),
          MyButtons(
            onTap: () async {
              await firestoreService.deleteAll();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('All students deleted', style: TextStyle(fontSize: 25.0),),
                backgroundColor: Colors.blue,
                ),
              );
            },
            text: 'Delete Allocated Students',
          ),
        ]));
  }
}
