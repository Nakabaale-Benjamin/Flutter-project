import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'customdropdown.dart'; // Import your custom dropdown
import 'textcustom.dart'; // Import your custom text field
import 'hall.dart';
import '../widget/button.dart';
import 'checkbox.dart'; // Import to handle navigation after form submission

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
  String? _selectedYearOfStudy;
  String? _selectedCollege;
  bool _hasDisability = false;
  bool _isContinuingResident = false;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        await FirebaseFirestore.instance.collection('students').add({
          'fullName': _fullNameController.text,
          'sex': _sexController.text,
          'registrationNumber': _registrationController.text,
          'email': _emailController.text,
          'yearOfStudy': _selectedYearOfStudy,
          'college': _selectedCollege,
          'hallOfAttachment': _hallOfAttachmentController.text,
          'hasDisability': _hasDisability,
          'isContinuingResident': _isContinuingResident,
          'timestamp': FieldValue.serverTimestamp(),
        });

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
                CustomTextField(
                  controller: _fullNameController,
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomDropdown(
                  value: _sexController.text.isNotEmpty ? _sexController.text : null,
                  label: 'Sex',
                  hint: 'Your sex',
                  items: ['Female', 'Male'],
                  onChanged: (newValue) {
                    setState(() {
                      _sexController.text = newValue ?? '';
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select your sex';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _registrationController,
                  label: 'Registration Number e.g 23/U/11071/ps',
                  hint: "Your University Reg no.",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your registration number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: "Your personal email",
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
                CustomDropdown(
                  value: _selectedYearOfStudy,
                  label: 'Year of Study',
                  hint: 'Select your year of study',
                  items: ['Year 1', 'Year 2', 'Year 3', 'Year 4', 'Year 5'],
                  onChanged: (newValue) {
                    setState(() {
                      _selectedYearOfStudy = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a year of study';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomDropdown(
                  value: _selectedCollege,
                  label: 'College',
                  hint: 'Select your college',
                  items: ['CAES', 'CoCIS', 'CHUSS', 'CEES', 'CEDAT', 'COBAMS', 'CoVAB', 'CHS','CoLAS', 'SCHOOL OF LAW'],
                  onChanged: (newValue) {
                    setState(() {
                      _selectedCollege = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a college';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomDropdown(
                  value: _hallOfAttachmentController.text.isNotEmpty ? _hallOfAttachmentController.text : null,
                  label: 'Hall Of Attachment',
                  hint: 'Select the hall you are attached to',
                  items: ['Africa', 'Mary Stuart', 'Complex', 'Nkrumah', 'Lumumba',"Nsibirwa","Livingstone","University Hall","Mitchell"], // Example halls
                  onChanged: (newValue) {
                    setState(() {
                      _hallOfAttachmentController.text = newValue ?? '';
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a hall of attachment';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                CustomCheckboxFormField(
                  label: 'Do you have a disability?',
                  hint: 'Check if you have a disability',
                  initialValue: _hasDisability,
                  onChanged: (value) {
                    setState(() {
                      _hasDisability = value ?? false;
                    });
                  },
                ),
                const SizedBox(height: 16),
                 CustomCheckboxFormField(
                  label: 'Are you a continuing resident?',
                  hint: 'Check if you are a continuing resident',
                  initialValue: _isContinuingResident,
                  onChanged: (value) {
                    setState(() {
                      _isContinuingResident = value ?? false;
                    });
                  },
                ),
                const SizedBox(height: 16),
                MyButtons(
                  onTap: _submitForm,
                  text: ('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
