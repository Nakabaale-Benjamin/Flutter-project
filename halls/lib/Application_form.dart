import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'hall.dart'; // Imported to handle navigation after form submission

// Create a new class for the success screen
class SubmissionSuccessScreen extends StatelessWidget {
  final String studentName;

  const SubmissionSuccessScreen({super.key, required this.studentName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Submission Successful"),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 100,
              ),
              const SizedBox(height: 20),
              Text(
                'Thank you, $studentName!',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Your form has been successfully submitted.',
                style: TextStyle(fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              const Text(
                'Please wait for the room allocation results.',
                style: TextStyle(fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
             ElevatedButton(
                onPressed: () {
                  // Navigate to the Hall screen
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Hall(),
                    ),
                    (Route<dynamic> route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    'Back to Home',
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class Student extends StatefulWidget {
  const Student({super.key});

  @override
  State<Student> createState() => _StudentState();
}

class _StudentState extends State<Student> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _sexController = TextEditingController();
  final TextEditingController _registrationController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _collegeController = TextEditingController();
  final TextEditingController _hallOfAttachmentController = TextEditingController();
  String _studentType = 'Fresher';  // Default value
  String? _points;
  String? _cgpa;

  String? _selectedStudentType;
  String? _selectedYearOfStudyValue;  // Renamed to avoid conflict
  String? _selectedCollege;
  bool _hasDisability = false;
  bool _isContinuingResident = false;

  // Updated _submitForm method to handle form submission and navigate to success screen
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Ensure _points and _cgpa are correctly populated
      print('_points: $_points');
      print('_cgpa: $_cgpa');

      try {
        await FirebaseFirestore.instance.collection('students').add({
          'fullName': _fullNameController.text,
          'sex': _sexController.text,
          'registrationNumber': _registrationController.text,
          'email': _emailController.text,
          'yearOfStudy': _selectedYearOfStudyValue,  // Use renamed variable
          'college': _selectedCollege,
          'hallOfAttachment': _hallOfAttachmentController.text,
          'studentType': _selectedStudentType,
          'points': _points ?? '',
          'cgpa': _cgpa ?? '',
          'hasDisability': _hasDisability,
          'isContinuingResident': _isContinuingResident,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Navigate to the success screen after successful submission
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubmissionSuccessScreen(
              studentName: _fullNameController.text,
            ),
          ),
        );
      } catch (e) {
        print('Error saving to Firestore: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving to Firestore: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: const Text("Hall Application Form"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'Enter your full name',
                    labelStyle: TextStyle(fontSize: 16, color: Colors.black),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                DropdownButtonFormField<String>(
                  value: _sexController.text.isNotEmpty ? _sexController.text : null,
                  decoration: const InputDecoration(
                    labelText: 'Sex',
                    hintText: "Your sex",
                    labelStyle: TextStyle(fontSize: 16, color: Colors.black),
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'Female',
                      child: Text('Female'),
                    ),
                    DropdownMenuItem(
                      value: 'Male',
                      child: Text('Male'),
                    ),
                  ],
                  onChanged: (String? newValue) {
                    _sexController.text = newValue ?? '';
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your sex';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _registrationController,
                  decoration: const InputDecoration(
                    labelText: 'Registration Number e.g 23/U/11071/ps',
                    hintText: "Your University Reg no.",
                    labelStyle: TextStyle(fontSize: 16, color: Colors.black),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your registration number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: "Your personal email",
                    labelStyle: TextStyle(fontSize: 16, color: Colors.black),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedYearOfStudyValue,  // Use renamed variable
                  decoration: const InputDecoration(
                    labelText: 'Year of Study',
                    hintText: "Your year of study e.g Year 1",
                    labelStyle: TextStyle(fontSize: 16, color: Colors.black),
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(value: 'Year 1', child: Text('Year 1')),
                    DropdownMenuItem(value: 'Year 2', child: Text('Year 2')),
                    DropdownMenuItem(value: 'Year 3', child: Text('Year 3')),
                    DropdownMenuItem(value: 'Year 4', child: Text('Year 4')),
                    DropdownMenuItem(value: 'Year 5', child: Text('Year 5')),
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedYearOfStudyValue = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your year of study';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                DropdownButtonFormField<String>(
                  value: _selectedCollege,
                  decoration: const InputDecoration(
                    labelText: 'College',
                    hintText: 'Select your college',
                    labelStyle: TextStyle(fontSize: 16, color: Colors.black),
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(value: 'CAES', child: Text('CAES')),
                    DropdownMenuItem(value: 'COCIS', child: Text('CoCIS')),
                    DropdownMenuItem(value: 'CHUSS', child: Text('CHUSS')),
                    DropdownMenuItem(value: 'CEES', child: Text('CEES')),
                    DropdownMenuItem(value: 'CEDAT', child: Text('CEDAT')),
                    DropdownMenuItem(value: 'COBAMS', child: Text('COBAMS')),
                    DropdownMenuItem(value: 'COVAB', child: Text('CoVAB')),
                    DropdownMenuItem(value: 'COLAS', child: Text('CoLAS')),
                    DropdownMenuItem(value: 'SOL', child: Text('SCHOOL OF LAW')),
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCollege = newValue;
                    });
                  },
                  validator: (value) => value == null || value.isEmpty ? 'Please select your college' : null,
                ),
                const SizedBox(height: 16),
                
                 DropdownButtonFormField<String>(
                  value: _hallOfAttachmentController.text.isNotEmpty ? _hallOfAttachmentController.text : null,
                  decoration: const InputDecoration(
                    labelText: 'Hall Of Attachment',
                    hintText: "Select the hall you are attached to",
                    labelStyle: TextStyle(fontSize: 16, color: Colors.black),
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(value: 'Africa', child: Text('Africa')),
                    DropdownMenuItem(value: 'Mary Stuart', child: Text('Mary Stuart')),
                    DropdownMenuItem(value: 'Compex', child: Text('Compex')),
                    DropdownMenuItem(value: 'Nkrumah', child: Text('Nkrumah')),
                    DropdownMenuItem(value: 'Lumumba', child: Text('Lumumba')),
                    DropdownMenuItem(value: 'Livingstone', child: Text('Livingstone')),
                    DropdownMenuItem(value: 'Mitchell', child: Text('Mitchell')),
                    DropdownMenuItem(value: 'University Hall', child: Text('University Hall')),
                    DropdownMenuItem(value: 'Nsibirwa', child: Text('Nsibirwa')),
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      _hallOfAttachmentController.text = newValue ?? '';
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your hall of attachment';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                DropdownButtonFormField<String>(
                  value: _studentType,
                  decoration: const InputDecoration(
                    labelText: 'Are you a fresher or a continuing student?',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Fresher', 'Continuing Student']
                      .map((label) => DropdownMenuItem(
                            child: Text(label),
                            value: label,
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _studentType = value!;
                    });
                  },
                ),
                const SizedBox(height: 20),
                if (_studentType == 'Fresher')
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Enter your points',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onSaved: (value) {
                      _points = value;
                    },
                  ),
                if (_studentType == 'Continuing Student')
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Enter your CGPA',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onSaved: (value) {
                      _cgpa = value;
                    },
                  ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedStudentType,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedStudentType = newValue;
                    });
                  },
                  items: const [
                    DropdownMenuItem(
                        value: 'Government', child: Text('Government Student')),
                    DropdownMenuItem(value: 'Private', child: Text('Private Student')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Student Type',
                    labelStyle: TextStyle(fontSize: 16, color: Colors.black),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a student type';
                    }
                    return null;
                  },
                ),
                
                CheckboxListTile(
                  title: const Text('Do you have a disability?'),
                  value: _hasDisability,
                  onChanged: (bool? newValue) {
                    setState(() {
                      _hasDisability = newValue ?? false;
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                CheckboxListTile(
                  title: const Text('Are you a continuing resident?'),
                  value: _isContinuingResident,
                  onChanged: (bool? newValue) {
                    setState(() {
                      _isContinuingResident = newValue ?? false;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Add Submit Button
                ElevatedButton(
                  onPressed: () {
                    _submitForm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    ),
                  ),
                  child: SizedBox(
                    width: 200,
                    height: 50,
                    child: Center(
                      child: const Text(
                        'Submit',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
