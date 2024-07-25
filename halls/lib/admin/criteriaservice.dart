import 'package:cloud_firestore/cloud_firestore.dart';
import 'criteriamodel.dart'; // Import the Criteria model

class CriteriaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'criteria'; // Firestore collection name

  Future<Criterias> getCriteria() async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection(_collection).doc('current').get();
      if (snapshot.exists) {
        return Criterias.fromMap(snapshot.data() as Map<String, dynamic>);
      } else {
        // Initialize with default values if not present
        Criterias defaultCriteria = Criterias(
          attachmentToHall: 0,
          governmentStudent: 0,
          disabled: 0,
          cgpa: 0.0,
          uace: 0.0,
          continuingResident: 0,
          privateStudent: 0,
        );
        defaultCriteria.calculateTotalPoints();
        return defaultCriteria;
      }
    } catch (e) {
      print('Error getting criteria: $e');
      rethrow;
    }
  }

  Future<void> updateCriteria(Criterias criteria) async {
    try {
      criteria.calculateTotalPoints();
      await _firestore.collection(_collection).doc('current').set(criteria.toMap());
    } catch (e) {
      print('Error updating criteria: $e');
      rethrow;
    }
  }

  Future<void> deleteCriteria() async {
    try {
      await _firestore.collection(_collection).doc('current').delete();
    } catch (e) {
      print('Error deleting criteria: $e');
      rethrow;
    }
  }
}