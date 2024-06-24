import 'package:flutter/material.dart';
import 'package:livestock_app/signup.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: ElevatedButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (BuildContext context) {
            return const Signup();
          }),
        );
      },
      child: const Text(
        'SIGNUP',
        style: TextStyle(
          color: Colors.red,
        ),
      ),
    ));
  }
}
