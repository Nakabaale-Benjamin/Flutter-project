import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'login.dart'; // Import your login screen
import 'student_model.dart'; // Import your Student model
import 'submissionsuccessScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Future.delayed(const Duration(seconds: 1));
  
  FlutterNativeSplash.remove();
  
  // Example data for students
  List<Student> studentsData = [
    Student(
      id: '1', // Replace with actual Firestore document ID or unique identifier
      firstName: 'John', 
      lastName: 'Doe',
      cgpa: 3,
      uacePoints: null,
      isAttachedToHall: true,
      isGovernmentStudent: true,
      isDisabled: true,
      isContinuingResident: true,
      isPrivateStudent: true, // Add this line
      isFresher: false, 
      gender: 'male', // Add gender
      roomNumber: null, // Make sure to include roomNumber if it's part of the constructor
      roomId: null, // Add roomId if needed
    ),
    // Add more students as needed
  ];
  
  runApp(MyApp(studentsData: studentsData));
}

class MyApp extends StatelessWidget {
  final List<Student> studentsData;

  const MyApp({Key? key, required this.studentsData}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "HALL BOOKING",
      theme: ThemeData(primarySwatch: Colors.green),
      // Assuming LoginScreen is where authentication happens
      home: const LoginScreen(),
      // Example of how you might add routes for navigation
      routes: {
        '/login': (context) => const LoginScreen(),
         '/success': (context) => SubmissionSuccessScreen(
              studentName: ModalRoute.of(context)!.settings.arguments as String,
            ),
      },
    );
  }
}
