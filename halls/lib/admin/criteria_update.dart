import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Criterias {
  int attachmentToHall;
  int governmentStudent;
  int disabled;
  double cgpa;
  double uace;
  int continuingResident;
  int privateStudent;
  int totalPoints;

  Criterias({
    required this.attachmentToHall,
    required this.governmentStudent,
    required this.disabled,
    required this.cgpa,
    required this.uace,
    required this.continuingResident,
    required this.privateStudent,
    this.totalPoints = 0,
  });

  // Convert a Criteria object into a Map
  Map<String, dynamic> toMap() {
    return {
      'attachmentToHall': attachmentToHall,
      'governmentStudent': governmentStudent,
      'disabled': disabled,
      'cgpa': cgpa,
      'uace': uace,
      'continuingResident': continuingResident,
      'privateStudent': privateStudent,
      'totalPoints': totalPoints,
    };
  }

  // Create a Criteria object from a Map
  factory Criterias.fromMap(Map<String, dynamic> map) {
    return Criterias(
      attachmentToHall: map['attachmentToHall'] ?? 0,
      governmentStudent: map['governmentStudent'] ?? 0,
      disabled: map['disabled'] ?? 0,
      cgpa: map['cgpa'] ?? 0.0,
      uace: map['uace'] ?? 0.0,
      continuingResident: map['continuingResident'] ?? 0,
      privateStudent: map['privateStudent'] ?? 0,
      totalPoints: map['totalPoints'] ?? 0,
    );
  }

  // Method to calculate total points
  void calculateTotalPoints() {
    int cgpaPoints = cgpa >= 3.5 ? 20 : 0;
    totalPoints = attachmentToHall +
                  governmentStudent +
                  disabled +
                  cgpaPoints +
                  continuingResident +
                  privateStudent;
  }
}

class CriteriaScreen extends StatefulWidget {
  const CriteriaScreen({Key? key}) : super(key: key);

  @override
  _CriteriaScreenState createState() => _CriteriaScreenState();
}

class _CriteriaScreenState extends State<CriteriaScreen> {
  final _formKey = GlobalKey<FormState>();
  late Criterias _criteria;

  final TextEditingController _attachmentToHallController = TextEditingController();
  final TextEditingController _governmentStudentController = TextEditingController();
  final TextEditingController _disabledController = TextEditingController();
  final TextEditingController _cgpaController = TextEditingController();
  final TextEditingController _uaceController = TextEditingController();
  final TextEditingController _continuingResidentController = TextEditingController();
  final TextEditingController _privateStudentController = TextEditingController();
  final TextEditingController _totalPointsController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'criteria';

  @override
  void initState() {
    super.initState();
    _loadCriteria();
  }

  Future<void> _loadCriteria() async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection(_collection).doc('current').get();
      if (snapshot.exists) {
        setState(() {
          _criteria = Criterias.fromMap(snapshot.data() as Map<String, dynamic>);
          _attachmentToHallController.text = _criteria.attachmentToHall.toString();
          _governmentStudentController.text = _criteria.governmentStudent.toString();
          _disabledController.text = _criteria.disabled.toString();
          _cgpaController.text = _criteria.cgpa.toString();
          _uaceController.text = _criteria.uace.toString();
          _continuingResidentController.text = _criteria.continuingResident.toString();
          _privateStudentController.text = _criteria.privateStudent.toString();
          _totalPointsController.text = _criteria.totalPoints.toString();
        });
      } else {
        // Initialize with default values if not present
        setState(() {
          _criteria = Criterias(
            attachmentToHall: 0,
            governmentStudent: 0,
            disabled: 0,
            cgpa: 0.0,
            uace: 0.0,
            continuingResident: 0,
            privateStudent: 0,
            totalPoints: 0,
          );
        });
      }
    } catch (e) {
      print('Error loading criteria: $e');
    }
  }

  void _calculateAndUpdateTotalPoints() {
    setState(() {
      _criteria = Criterias(
        attachmentToHall: int.tryParse(_attachmentToHallController.text) ?? 0,
        governmentStudent: int.tryParse(_governmentStudentController.text) ?? 0,
        disabled: int.tryParse(_disabledController.text) ?? 0,
        cgpa: double.tryParse(_cgpaController.text) ?? 0.0,
        uace: double.tryParse(_uaceController.text) ?? 0.0,
        continuingResident: int.tryParse(_continuingResidentController.text) ?? 0,
        privateStudent: int.tryParse(_privateStudentController.text) ?? 0,
      );
      _criteria.calculateTotalPoints();
      _totalPointsController.text = _criteria.totalPoints.toString();
    });
  }

  Future<void> _updateCriteria() async {
    if (_formKey.currentState!.validate()) {
      _calculateAndUpdateTotalPoints();

      try {
        await _firestore.collection(_collection).doc('current').set(_criteria.toMap());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Criteria updated successfully')),
        );
      } catch (e) {
        print('Error updating criteria: $e');
      }
    }
  }

  Future<void> _deleteCriteria() async {
    try {
      await _firestore.collection(_collection).doc('current').delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Criteria deleted successfully')),
      );
      // Optionally, reset form fields or navigate away
    } catch (e) {
      print('Error deleting criteria: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Criteria'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _attachmentToHallController,
                decoration: const InputDecoration(labelText: 'Attachment to Hall'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onChanged: (value) => _calculateAndUpdateTotalPoints(),
              ),
              TextFormField(
                controller: _governmentStudentController,
                decoration: const InputDecoration(labelText: 'Government Student'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onChanged: (value) => _calculateAndUpdateTotalPoints(),
              ),
              TextFormField(
                controller: _disabledController,
                decoration: const InputDecoration(labelText: 'Disabled'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onChanged: (value) => _calculateAndUpdateTotalPoints(),
              ),
              TextFormField(
                controller: _cgpaController,
                decoration: const InputDecoration(labelText: 'CGPA'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty || double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onChanged: (value) => _calculateAndUpdateTotalPoints(),
              ),
              TextFormField(
                controller: _uaceController,
                decoration: const InputDecoration(labelText: 'UACE'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty || double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onChanged: (value) => _calculateAndUpdateTotalPoints(),
              ),
              TextFormField(
                controller: _continuingResidentController,
                decoration: const InputDecoration(labelText: 'Continuing Resident'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onChanged: (value) => _calculateAndUpdateTotalPoints(),
              ),
              TextFormField(
                controller: _privateStudentController,
                decoration: const InputDecoration(labelText: 'Private Student'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onChanged: (value) => _calculateAndUpdateTotalPoints(),
              ),
              TextFormField(
                controller: _totalPointsController,
                decoration: const InputDecoration(labelText: 'Total Points'),
                readOnly: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateCriteria,
                child: const Text('Update Criteria'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _deleteCriteria,
                child: const Text('Delete Criteria'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
