import 'package:flutter/material.dart';
import 'hall_update.dart';
import 'package:halls/criteria_update.dart';
import '../widget/button.dart';
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
    body: Center(
      child: Column(
        children: [
          MyButtons(onTap:  () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (BuildContext context) {
                      return  HallsScreen();
                    }));
                  }, text: "Update hall info"),
                  const SizedBox(
                    height: 10,
                  ),
                  MyButtons(onTap:  () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (BuildContext context) {
                      return  CriteriaScreen();
                    }));
                  }, text: "Manage Criteria ")
                   
        ],
      ),
    ),
    );
  }
}