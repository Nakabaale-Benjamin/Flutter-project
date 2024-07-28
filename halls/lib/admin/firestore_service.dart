import 'package:cloud_firestore/cloud_firestore.dart';
import 'progress_service.dart';
import 'progress_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final ProgressService _progressService = ProgressService();

   Future<Map<String, dynamic>> fetchStudentDetails(String id) async {
    final snapshot = await _db.collection('students').doc(id).get();
    return snapshot.data() as Map<String, dynamic>;
  }

  // Fetch criteria from Firestore
  Future<Map<String, dynamic>> fetchCriteria() async {
    try {
      DocumentSnapshot snapshot =
          await _db.collection('criteria').doc('current').get();
      final data = snapshot.data() as Map<String, dynamic>?; // Fetch and cast data
      return data ?? {}; // Return an empty map if data is null
    } catch (e) {
      print('Error fetching criteria: $e');
      return {}; // Return an empty map in case of an error
    }
  }

  // Fetch student IDs from Firestore
  Future<List<String>> fetchStudentIds() async {
    try {
      QuerySnapshot querySnapshot = await _db.collection('students').get();
      List<String> ids = querySnapshot.docs.map((doc) => doc.id).toList();
      return ids;
    } catch (e) {
      print('Error fetching student IDs: $e');
      return []; // Return an empty list in case of an error
    }
  }

  // Fetch student data for given IDs
  Future<List<Map<String, dynamic>?>> fetchStudents(List<String> ids) async {
    List<Map<String, dynamic>?> studentDataList = [];

    for (String id in ids) {
      try {
        DocumentSnapshot snapshot =
            await _db.collection('students').doc(id).get();
        if (!snapshot.exists) {
          studentDataList.add(null);
        } else {
          studentDataList.add(snapshot.data() as Map<String, dynamic>?);
        }
      } catch (e) {
        print('Error fetching student document with ID: $id. Error: $e');
        studentDataList.add(null);
      }
    }

    return studentDataList;
  }

  // Fetch all halls data
  Future<List<Map<String, dynamic>?>> fetchAllHalls() async {
    try {
      QuerySnapshot querySnapshot = await _db.collection('halls').get();
      List<Map<String, dynamic>?> hallDataList = querySnapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>?;
      }).toList();
      return hallDataList;
    } catch (e) {
      print('Error fetching halls data: $e');
      return []; // Return an empty list in case of an error
    }
  }

  // Get available bedspace from hall document by hall ID
  Future<int?> _getAvailableBedspace(String hallId) async {

    try {
      DocumentSnapshot hallDoc = await _db.collection('halls').doc(hallId).get();

      if (!hallDoc.exists) {
        return null;
      }

      final hallData = hallDoc.data() as Map<String, dynamic>?;

      if (hallData == null) {

        return null;
      }

      final int rooms = hallData['rooms'] as int? ?? 0;
      final int bedspacesPerRoom = hallData['bedspace'] as int? ?? 0;

      final int totalBedspaces = rooms * bedspacesPerRoom;

      return totalBedspaces;

    } catch (e) {
      print('Error fetching hall data for ID: $hallId. Error: $e');
      return null;
    }
  }

  // Process all students and save their progress
  Future<void> processAllStudents() async {
    try {
      final criteria = await fetchCriteria();
      final studentIds = await fetchStudentIds();
      final studentDataList = await fetchStudents(studentIds);
      final hallsData = await fetchAllHalls(); // Fetch all halls data

      // Track assigned bedspaces
      final Map<String, int> hallBedspaceAssignments = {};

      for (int i = 0; i < studentIds.length; i++) {
        final id = studentIds[i];
        final studentData = studentDataList[i];

        if (studentData == null) {
          continue;
        }
        int weight = 0;

        try {
          // Safely cast and validate data
          final cgpa = _getNumFromMap(studentData, 'cgpa');
          final governmentOrPrivateStudent = studentData['governmentOrPrivateStudent'] as String?;
          final hallOfAttachment = studentData['hallOfAttachment'] as String?;
          final hasDisability = studentData['hasDisability'] as bool?;
          final isContinuingResident =
              studentData['isContinuingResident'] as bool?;
          final points = _getNumFromMap(studentData, 'points');

          final criteriaCgpa = _getNumFromMap(criteria, 'cgpa');
          final criteriaGovernmentStudent =
              _getNumFromMap(criteria, 'governmentStudent');
          final criteriaAttachmentToHall =
              _getNumFromMap(criteria, 'attachmentToHall');
          final criteriaDisabled = _getNumFromMap(criteria, 'disabled');
          final criteriaContinuingResident =
              _getNumFromMap(criteria, 'continuingResident');
          final criteriaPrivateStudent =
              _getNumFromMap(criteria, 'privateStudent');
          final criteriaUace = _getNumFromMap(criteria, 'uace');

          // Calculate points based on criteria
          if (cgpa != null && criteriaCgpa != null && cgpa >= 3) {
            weight += criteriaCgpa.toInt();
          }

          if (governmentOrPrivateStudent == 'Government Student') {
            weight += criteriaGovernmentStudent?.toInt() ?? 0;
          }

          if (hallOfAttachment == studentData['hallOfAttachment']) {
             weight += criteriaAttachmentToHall?.toInt() ?? 0;
          }

          if (hasDisability == true) {
            weight += criteriaDisabled?.toInt() ?? 0;
          }

          if (isContinuingResident == true) {
             weight += criteriaContinuingResident?.toInt() ?? 0;
          }

          if (governmentOrPrivateStudent == 'Private Student') {
            weight += criteriaPrivateStudent?.toInt() ?? 0;
          }

          if (points != null && points >= 15) {
             weight += criteriaUace?.toInt() ?? 0;
          }

          // Check if the points exceed the threshold
          if (weight >= 60) {
            final hallName = studentData['hallOfAttachment'] as String?;
            if (hallName != null) {
              // Get available bedspace
              int? totalBedspaces = await _getAvailableBedspace(hallName);
              if (totalBedspaces != null) {
                // Assign bedspace
                int assignedBedspace = (hallBedspaceAssignments[hallName] ?? 0) + 1;
                if (assignedBedspace <= totalBedspaces) {
                  hallBedspaceAssignments[hallName] = assignedBedspace;

                  final progress = Progress(
                    name: studentData['fullName'] as String,
                    registrationNumber: studentData['registrationNumber'] as String,
                    hall: hallName,
                    bedspace: assignedBedspace,
                    weight:  weight,
                  );
                  await _progressService.saveProgress(id, progress);
                  print('Progress saved: $progress');
                } else {
                  // No available bedspaces
                  final progress = Progress(
                    name: studentData['fullName'] as String,
                    registrationNumber: studentData['registrationNumber'] as String,
                    hall: hallName,
                    bedspace: null,
                    weight:  weight,
                  );
                  await _progressService.saveProgress(id, progress);
                }
              } else {
                // Error in fetching bedspaces
                final progress = Progress(
                  name: studentData['fullName'] as String,
                  registrationNumber: studentData['registrationNumber'] as String,
                  hall: hallName,
                  bedspace: null,
                  weight:  weight,
                );
                await _progressService.saveProgress(id, progress);
              }
            } else {
                            final progress = Progress(
                name: studentData['fullName'] as String,
                registrationNumber: studentData['registrationNumber'] as String,
                hall: null,
                bedspace: null,
                weight:  weight,
              );
              await _progressService.saveProgress(id, progress);
            }
          } else {
            final progress = Progress(
              name: studentData['fullName'] as String,
              registrationNumber: studentData['registrationNumber'] as String,
              hall: null,
              bedspace: null,
              weight:  weight,
            );
            await _progressService.saveProgress(id, progress);
          }
        } catch (e) {
          print('Error calculating points for student ID: $id. Error: $e');
        }
      }
    } catch (e) {
      print('Error processing all students: $e');
    }
  }

   // Fetch all students from Firestore
  Future<List<Map<String, dynamic>>> fetchAllStudents() async {
    try {
      QuerySnapshot querySnapshot = await _db.collection('students').get();
      return querySnapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();
    } catch (e) {
      print('Error fetching all students: $e');
      return [];
    }
  }

  //fetch all Progress


  Future<List<Map<String, dynamic>>> fetchAllProgress() async {
    try {
      // Fetch the documents from the 'progress' collection
      QuerySnapshot querySnapshot = await _db.collection('progress').get();
      
      // Map each document to a Map<String, dynamic> and return the list
      return querySnapshot.docs.map((doc) {
        // Ensure the data is cast to a Map<String, dynamic>
        final data = doc.data() as Map<String, dynamic>;
        
        // Optionally handle specific fields if needed (e.g., type conversions)
        return {
          'name': data['name'] ?? 'Not Allocated',
          'registrationNumber': data['registrationNumber'] ?? 'Not Allocated',
          'hall': data['hall'] ?? 'N/A',
          'bedspace': data['bedspace'] ?? 'Not Allocated',
          'weight': data['weight'] ?? 0, // Default to 0 if 'points' is not present
        };
      }).toList();
    } catch (e) {
      // Log the error
      print('Error fetching all progress data: $e');
      
      // Return an empty list if there's an error
      return [];
    }
  }
}

  // Helper method to safely extract and convert numerical values
  num? _getNumFromMap(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is num) {
      return value;
    } else if (value is String) {
      return num.tryParse(value);
    }
    return null;
  }

