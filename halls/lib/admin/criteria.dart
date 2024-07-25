import 'package:flutter/material.dart';
import 'package:halls/admin/hall_update.dart';

class Criteria extends StatefulWidget {
  const Criteria({super.key});

  @override
  State<Criteria> createState() => _CriteriaState();
}

class _CriteriaState extends State<Criteria> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(title: const Text("UPDATE APP INFO"),),
    body: Column(
      children: [
        TextButton(onPressed:  () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (BuildContext context) {
                    return  EditHallScreen();
                  }));
                }, child: const Text("Update hall info"))
      ],
    ),
    );
  }
}