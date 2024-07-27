import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widget/button.dart';

class FirestoreService {
  final CollectionReference progressCollection =
      FirebaseFirestore.instance.collection('progress');

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

class ProgressDelete extends StatelessWidget {
  final FirestoreService firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text("Delete Allocation",
          style: TextStyle(
                    fontSize: 25
                    ,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),),
        ),
        body: Column(children: [
          MyButtons(
            onTap: () async {
              await firestoreService.deleteAll();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('All students deleted')),
              );
            },
            text: 'Delete All Students',
          )
        ]));
  }
}
