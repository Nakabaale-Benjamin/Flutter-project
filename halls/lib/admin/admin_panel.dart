import 'package:flutter/material.dart';
import 'package:halls/admin/criteria.dart';
import 'package:halls/admin/message.dart';
import 'package:halls/services/authentication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:halls/login.dart';


class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  int currentpage = 0;
  List<Widget> pages = const [
    Message(),
    LoginScreen(),
  ];
  final AuthMethod _authMethod = AuthMethod();
  late User? _user;

  @override
  void initState() {
    super.initState();
    _user = _authMethod.getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("ADMIN PANEL"),
          backgroundColor: Colors.green,
          actions: [
            DrawerButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (BuildContext context) {
                  return const CriteriaScreen();
                }));
              },
            )
          ],
        ),
        body: Center(
            child: ListView(scrollDirection: Axis.vertical, children: [
          Container(
            color: Colors.green,
            child: SizedBox(
              height: 50,
              child: Center(
                  child: _user != null
                      ? Text(
                          'Hi:  ${_user?.displayName ?? 'No name provided'}',
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        )
                      : const Text(" No user name specified")),
            ),
          ),
        ])),
        bottomNavigationBar: NavigationBarTheme(
          data: const NavigationBarThemeData(
            indicatorColor: Colors.green,
          ),
          child: NavigationBar(
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
              NavigationDestination(
                  icon: Icon(Icons.message), label: 'Notification'),
              NavigationDestination(icon: Icon(Icons.logout), label: 'Logout'),
            ],
            onDestinationSelected: (int index) async {
              if (index == 2) {
                // Perform logout
                await AuthMethod().signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              } else if (index == 1) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Message()),
                );
              }
              setState(() {
                currentpage = index;
              });
            },
            selectedIndex: currentpage,
          ),
        ));
  }
}
