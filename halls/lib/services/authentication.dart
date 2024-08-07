import 'package:firebase_auth/firebase_auth.dart';

class AuthMethod {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign up user
  Future<String> signupUser({
    required String email,
    required String password,
    required String name,
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty || password.isNotEmpty || name.isNotEmpty) {
        // Register user with email and password
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Update user display name
        await cred.user!.updateProfile(displayName: name);
        await _auth.currentUser!.reload(); // Reload the user
        User? updatedUser = _auth.currentUser; // Get the updated user

        res = "success";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Log in user
  Future<String> loginUser({required String email, required String password}) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = userCredential.user;
      return user?.uid ?? "error";
    } catch (e) {
      print('Error logging in: $e');
      return "error";
    }
  }

  // Sign out user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user details
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
