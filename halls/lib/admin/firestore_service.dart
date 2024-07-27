import 'package:cloud_firestore/cloud_firestore.dart';
import 'progress_service.dart';
import 'progress_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final ProgressService _progressService = ProgressService();

  // Fetch criteria from Firestore
  Future<Map<String, dynamic>> fetchCriteria() async {
    try {
      DocumentSnapshot snapshot =
          await _db.collection('criteria').doc('current').get();
      final data = snapshot.data() as Map<String, dynamic>?; // Fetch and cast data
      print('Criteria data: $data'); // Log criteria data
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
      print('Fetched student IDs: $ids');
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
          print('No student document found with ID: $id');
          studentDataList.add(null);
        } else {
          print('Fetched student document: ${snapshot.data()}');
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
      print('Fetched all hall data: $hallDataList');
      return hallDataList;
    } catch (e) {
      print('Error fetching halls data: $e');
      return []; // Return an empty list in case of an error
    }
  }

  // Get available bedspace from hall document by hall ID
  Future<int?> _getAvailableBedspace(String hallId) async {
    print('Searching for hall ID: $hallId'); // Debug print at the start

    try {
      DocumentSnapshot hallDoc = await _db.collection('halls').doc(hallId).get();

      if (!hallDoc.exists) {
        print('Hall data not found for ID: $hallId');
        return null;
      }

      final hallData = hallDoc.data() as Map<String, dynamic>?;

      if (hallData == null) {
        print('No data found for hall ID: $hallId');
        return null;
      }

      print('Hall data found: $hallData'); // Debug print for found data

      final int rooms = hallData['rooms'] as int? ?? 0;
      final int bedspacesPerRoom = hallData['bedspace'] as int? ?? 0;

      final int totalBedspaces = rooms * bedspacesPerRoom;

      print('Fetched total bedspaces: $totalBedspaces for hall ID: $hallId');
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
          print('Student data not found for uid: $id');
          continue;
        }

        print('Student data: $studentData');

        int points = 0;

        try {
          // Safely cast and validate data
          final cgpa = _getNumFromMap(studentData, 'cgpa');
          final studentType = studentData['studentType'] as String?;
          final hallOfAttachment = studentData['hallOfAttachment'] as String?;
          final hasDisability = studentData['hasDisability'] as bool?;
          final isContinuingResident =
              studentData['isContinuingResident'] as bool?;
          final uace = _getNumFromMap(studentData, 'uace');

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
          if (cgpa != null && criteriaCgpa != null && cgpa >= criteriaCgpa) {
            points += criteriaCgpa.toInt();
          }

          if (studentType == 'Government') {
            points += criteriaGovernmentStudent?.toInt() ?? 0;
          }

          if (hallOfAttachment == studentData['hallOfAttachment']) {
            points += criteriaAttachmentToHall?.toInt() ?? 0;
          }

          if (hasDisability == true) {
            points += criteriaDisabled?.toInt() ?? 0;
          }

          if (isContinuingResident == true) {
            points += criteriaContinuingResident?.toInt() ?? 0;
          }

          if (studentType == 'Private') {
            points += criteriaPrivateStudent?.toInt() ?? 0;
          }

          if (uace != null && uace >= 10) {
            points += criteriaUace?.toInt() ?? 0;
          }

          // Check if the points exceed the threshold
          if (points > 50) {
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
                    points: points,
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
                    points: points,
                  );
                  await _progressService.saveProgress(id, progress);
                  print('Progress saved with no available bedspace: $progress');
                }
              } else {
                // Error in fetching bedspaces
                final progress = Progress(
                  name: studentData['fullName'] as String,
                  registrationNumber: studentData['registrationNumber'] as String,
                  hall: hallName,
                  bedspace: null,
                  points: points,
                );
                await _progressService.saveProgress(id, progress);
                print('Progress saved with no available bedspaces: $progress');
              }
            } else {
                            final progress = Progress(
                name: studentData['fullName'] as String,
                registrationNumber: studentData['registrationNumber'] as String,
                hall: null,
                bedspace: null,
                points: points,
              );
              await _progressService.saveProgress(id, progress);
              print('Progress saved with no hall name: $progress');
            }
          } else {
            final progress = Progress(
              name: studentData['fullName'] as String,
              registrationNumber: studentData['registrationNumber'] as String,
              hall: null,
              bedspace: null,
              points: points,
            );
            await _progressService.saveProgress(id, progress);
            print('Progress saved with low points: $progress');
          }
        } catch (e) {
          print('Error calculating points for student ID: $id. Error: $e');
        }
      }
    } catch (e) {
      print('Error processing all students: $e');
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
}
