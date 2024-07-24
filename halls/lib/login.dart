import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'widget/button.dart';
import 'package:halls/forgot_password.dart';
import 'services/authentication.dart';
import 'widget/text_field.dart';
import 'signup.dart';
import 'hall.dart';
import 'admin/admin_panel.dart'; // Assuming you have an AdminPanel screen

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  Future<String?> getUserRole(String uid) async {
    try {
      print('Fetching user data for UID: $uid');
      DocumentSnapshot document = await FirebaseFirestore.instance
          .collection('users') // Ensure this is the correct collection path
          .doc(uid)
          .get();

      if (document.exists) {
        print('User document found: ${document.data()}');
        return document['role'];
      } else {
        print('User data not found for UID: $uid');
        return null;
      }
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  void loginUser() async {
    setState(() {
      isLoading = true;
    });

    // Log in the user using your AuthMethod
    String uid = await AuthMethod().loginUser(
        email: emailController.text, password: passwordController.text);

    if (uid != "error") {
      // Debug: Print UID
      print('Logged in user UID: $uid');

      // Fetch user role
      String? role = await getUserRole(uid);

      setState(() {
        isLoading = false;
      });

      if (role != null) {
        print('User role: $role');
        if (role == "student") {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (BuildContext context) {
              return const Hall();
            }),
          );
        } else if (role == "admin") {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (BuildContext context) {
              return const AdminPanel(); // Assuming you have an AdminPanel screen
            }),
          );
        } else {
          print('Unknown user role: $role');
        }
      } else {
        print('User data not found for UID: $uid');
      }
    } else {
      setState(() {
        isLoading = false;
      });
      // Show error
      print('Error logging in');
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: height / 2.7,
                  child: Image.asset('assets/images/makerere.png'),
                ),
                TextFieldInput(
                  icon: Icons.person,
                  textEditingController: emailController,
                  hintText: 'Enter your webmail',
                  textInputType: TextInputType.text,
                ),
                TextFieldInput(
                  icon: Icons.lock,
                  textEditingController: passwordController,
                  hintText: 'Enter your password',
                  textInputType: TextInputType.text,
                  isPass: true,
                ),
                const ForgotPassword(),
                MyButtons(onTap: loginUser, text: "Log In"),
                Row(
                  children: [
                    Expanded(
                      child: Container(height: 1, color: Colors.black26),
                    ),
                    const Text("  or  "),
                    Expanded(
                      child: Container(height: 1, color: Colors.black26),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 100),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? "),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SignupScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "SignUp",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
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
