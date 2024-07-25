import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final CollectionReference criteriaCollection = _firestore.collection('criteria');

// Fetch Criteria
Future<Map<String, dynamic>> fetchCriteria() async {
  DocumentSnapshot doc = await criteriaCollection.doc('hall_criteria').get();
  return doc.data() as Map<String, dynamic>;
}

// Update Criteria
Future<void> updateCriteria(Map<String, dynamic> criteria) async {
  await criteriaCollection.doc('hall_criteria').update(criteria);
}

class AdminCriteriaScreen extends StatefulWidget {
  @override
  _AdminCriteriaScreenState createState() => _AdminCriteriaScreenState();
}

class _AdminCriteriaScreenState extends State<AdminCriteriaScreen> {
  Map<String, dynamic> criteria = {
    "attachment_to_hall": 20,
    "government_student": 15,
    "disabled": 25,
    "cgpa_or_uace_results": 20,
    "continuing_resident": 10,
    "private_student": 10
  };

  @override
  void initState() {
    super.initState();
    _loadCriteria();
  }

  Future<void> _loadCriteria() async {
    Map<String, dynamic> fetchedCriteria = await fetchCriteria();
    setState(() {
      criteria = fetchedCriteria;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adjust Criteria'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ...criteria.keys.map((key) {
              return TextField(
                decoration: InputDecoration(
                  labelText: key.replaceAll('_', ' ').toUpperCase(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    criteria[key] = int.parse(value);
                  });
                },
                controller: TextEditingController(
                  text: criteria[key]?.toString() ?? '0',
                ),
              );
            }).toList(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await updateCriteria(criteria);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Criteria Updated')),
                );
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
