import 'package:cloud_firestore/cloud_firestore.dart';
import 'progress_model.dart';

class ProgressService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Save a Progress object to the Firestore 'progress' collection
  Future<void> saveProgress(String studentId, Progress progress) async {
    try {
      await _db.collection('progress').doc(studentId).set(progress.toMap());
      print('Progress for student $studentId saved successfully.');
    } catch (e) {
      print('Error saving progress for student $studentId: $e');
    }
  }

  // Fetch a Progress document by student ID
  Future<Progress?> fetchProgress(String studentId) async {
    try {
      DocumentSnapshot snapshot = await _db.collection('progress').doc(studentId).get();
      if (snapshot.exists) {
        return Progress.fromMap(snapshot.data() as Map<String, dynamic>);
      } else {
        print('No progress document found for student $studentId.');
        return null;
      }
    } catch (e) {
      print('Error fetching progress for student $studentId: $e');
      return null;
    }
  }

  // Fetch all progress documents (useful for debugging or admin tasks)
  Future<List<Progress>> fetchAllProgress() async {
    try {
      QuerySnapshot snapshot = await _db.collection('progress').get();
      return snapshot.docs.map((doc) => Progress.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error fetching all progress: $e');
      return [];
    }
  }
}
