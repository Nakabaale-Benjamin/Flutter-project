import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widget/text_field.dart'; // Import your custom TextFieldInput widget
import '../widget/button.dart'; // Import your custom Button widget

class Criterias {
  int passmark;
  double allowed_CGPA;
  double allowed_UACE_points;
  int attachmentToHall;
  int governmentStudent;
  int disabled;
  double cgpa;
  double uace;
  int continuingResident;
  int privateStudent;
  int totalPoints;

  Criterias({
    required this.passmark,
    required this.allowed_CGPA,
    required this.allowed_UACE_points,
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
      'passmark': passmark,
      'allowed_CGPA': allowed_CGPA,
      'allowed_UACE_points': allowed_UACE_points,
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
      passmark: map['passmark']?? 0,
      allowed_CGPA: map['allowed_CGPA']?? 0,
      allowed_UACE_points: map['allowed_UACE_points']?? 0,
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
  @override
  _CriteriaScreenState createState() => _CriteriaScreenState();
}

class _CriteriaScreenState extends State<CriteriaScreen> {
  final _formKey = GlobalKey<FormState>();
  Criterias? _criteria;

  final TextEditingController _passmarkController = TextEditingController();
  final TextEditingController _allowed_CGPAController = TextEditingController();
  final TextEditingController _allowed_UACE_pointsController = TextEditingController();
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

          _passmarkController.text = _criteria!.passmark.toString();
          _allowed_CGPAController.text = _criteria!.allowed_CGPA.toString();
          _allowed_UACE_pointsController.text = _criteria!.allowed_UACE_points.toString();
          _attachmentToHallController.text = _criteria!.attachmentToHall.toString();
          _governmentStudentController.text = _criteria!.governmentStudent.toString();
          _disabledController.text = _criteria!.disabled.toString();
          _cgpaController.text = _criteria!.cgpa.toString();
          _uaceController.text = _criteria!.uace.toString();
          _continuingResidentController.text = _criteria!.continuingResident.toString();
          _privateStudentController.text = _criteria!.privateStudent.toString();
          _totalPointsController.text = _criteria!.totalPoints.toString();
        });
      } else {
        setState(() {
          _criteria = Criterias(
            passmark: 0,
            allowed_CGPA: 0,
            allowed_UACE_points: 0,
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
        passmark:  int.tryParse(_passmarkController.text) ?? 0,
        allowed_CGPA: double.tryParse(_allowed_CGPAController.text) ?? 0.0,
        allowed_UACE_points: double.tryParse(_allowed_UACE_pointsController.text) ?? 0.0,
        attachmentToHall: int.tryParse(_attachmentToHallController.text) ?? 0,
        governmentStudent: int.tryParse(_governmentStudentController.text) ?? 0,
        disabled: int.tryParse(_disabledController.text) ?? 0,
        cgpa: double.tryParse(_cgpaController.text) ?? 0.0,
        uace: double.tryParse(_uaceController.text) ?? 0.0,
        continuingResident: int.tryParse(_continuingResidentController.text) ?? 0,
        privateStudent: int.tryParse(_privateStudentController.text) ?? 0,
      );
      _criteria!.calculateTotalPoints();
      _totalPointsController.text = _criteria!.totalPoints.toString();
    });
  }

  Future<void> _updateCriteria() async {
    if (_formKey.currentState!.validate()) {
      _calculateAndUpdateTotalPoints();

      try {
        await _firestore.collection(_collection).doc('current').set(_criteria!.toMap());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Criteria updated successfully', style: TextStyle(fontSize: 25.0),),
                backgroundColor: Colors.blue,)
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
        SnackBar(content: Text('Criteria deleted successfully', style: TextStyle(fontSize: 25.0),),
                backgroundColor: Colors.blue,)
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
        title: const Text('Criteria Details'),
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false,
      ),
      body: _criteria == null 
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text("Passmark", style: TextStyle(color: Colors.blue, fontSize: 20.0,fontWeight: FontWeight.bold),),
                    TextFieldInput(
                      textEditingController: _passmarkController,
                      hintText: 'Passmark',
                      textInputType: TextInputType.number,
                      icon: Icons.verified_user,
                      onChanged: (value) => _calculateAndUpdateTotalPoints(),
                    ),
  
                    const Text("Required CGPA", style: TextStyle(color: Colors.blue,fontSize: 20.0,fontWeight: FontWeight.bold),),
                    TextFieldInput(
                      textEditingController: _allowed_CGPAController,
                      hintText: 'allowed_CGPA',
                      textInputType: TextInputType.number,
                      icon: Icons.grade,
                      onChanged: (value) => _calculateAndUpdateTotalPoints(),
                    ),
                     
                    const Text("Required UACE points", style: TextStyle(color: Colors.blue,fontSize: 20.0,fontWeight: FontWeight.bold),),
                    TextFieldInput(
                      textEditingController: _allowed_UACE_pointsController,
                      hintText: 'allowed_UACE_points',
                      textInputType: TextInputType.number,
                      icon: Icons.school,
                      onChanged: (value) => _calculateAndUpdateTotalPoints(),
                    ),
                     
                    const Text("Attachment to hall reward", style: TextStyle(color: Colors.blue,fontSize: 20.0,fontWeight: FontWeight.bold),),
                    TextFieldInput(
                      textEditingController: _attachmentToHallController,
                      hintText: 'Attachment to Hall',
                      textInputType: TextInputType.number,
                      icon: Icons.attach_file,
                      onChanged: (value) => _calculateAndUpdateTotalPoints(),
                    ),
                    
                    const Text("Government Student Reward", style: TextStyle(color: Colors.blue,fontSize: 20.0,fontWeight: FontWeight.bold),),
                    TextFieldInput(
                      textEditingController: _governmentStudentController,
                      hintText: 'Government Student',
                      textInputType: TextInputType.number,
                      icon: Icons.account_balance,
                      onChanged: (value) => _calculateAndUpdateTotalPoints(),
                    ),
                    
                    const Text("Disability Reward", style: TextStyle(color: Colors.blue,fontSize: 20.0,fontWeight: FontWeight.bold),),
                    TextFieldInput(
                      textEditingController: _disabledController,
                      hintText: 'Disabled',
                      textInputType: TextInputType.number,
                      icon: Icons.accessibility,
                      onChanged: (value) => _calculateAndUpdateTotalPoints(),
                    ),
                    
                    const Text("CGPA reward", style: TextStyle(color: Colors.blue,fontSize: 20.0,fontWeight: FontWeight.bold),),
                    TextFieldInput(
                      textEditingController: _cgpaController,
                      hintText: 'CGPA REWARD',
                      textInputType: TextInputType.numberWithOptions(decimal: true),
                      icon: Icons.grade,
                      onChanged: (value) => _calculateAndUpdateTotalPoints(),
                    ),
                    
                    const Text("UACE Reward", style: TextStyle(color: Colors.blue,fontSize: 20.0,fontWeight: FontWeight.bold),),
                    TextFieldInput(
                      textEditingController: _uaceController,
                      hintText: 'UACE REWARD',
                      textInputType: TextInputType.numberWithOptions(decimal: true),
                      icon: Icons.school,
                      onChanged: (value) => _calculateAndUpdateTotalPoints(),
                    ),
                    
                    const Text("Continuing Student Reward", style: TextStyle(color: Colors.blue,fontSize: 20.0,fontWeight: FontWeight.bold),),
                    TextFieldInput(
                      textEditingController: _continuingResidentController,
                      hintText: 'Continuing Student',
                      textInputType: TextInputType.number,
                      icon: Icons.home,
                ),
                  
                    const Text("Private Student Reward", style: TextStyle(color: Colors.blue,fontSize: 20.0,fontWeight: FontWeight.bold),),
                    TextFieldInput(
                      textEditingController: _privateStudentController,
                      hintText: 'Private Student',
                      textInputType: TextInputType.number,
                      icon: Icons.person,
                      onChanged: (value) => _calculateAndUpdateTotalPoints(),
                    ),
                    SizedBox(height: 16),
                    const Text("Total Points", style: TextStyle(color: Colors.blue,fontSize: 20.0,fontWeight: FontWeight.bold),),
                    TextFieldInput(
                      textEditingController: _totalPointsController,
                      hintText: 'Total Points',
                      textInputType: TextInputType.number,
                      icon: Icons.star,
                      readOnly: true,
                    ),
                    SizedBox(height: 20),
                    MyButtons(
                      onTap: _updateCriteria,
                      text: "Update Criteria",
                    ),
                    SizedBox(height: 20),
                    MyButtons(
                      onTap: _deleteCriteria,
                      text: "Delete Criteria",
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
