import 'package:flutter/material.dart';
import 'package:halls/hall.dart';
import 'package:halls/profile.dart';
import 'admin/progressScreen.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});
 
  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero, 
        children: [
          SizedBox(
            height: 50,
          ),
        ListTile(
          
  leading: Icon(Icons.person),
  title: Text('Profile',style: TextStyle(
          fontWeight: FontWeight.bold,
         fontSize:20.0,
         color: Colors.blue,
        )),
              onTap: () {
              Navigator.of(context)
                    .push(MaterialPageRoute(builder: (BuildContext context) {
                  return const ProfilePage
                  ();
                }));
            },
),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notifications',style: TextStyle(
          fontWeight: FontWeight.bold,
         fontSize:20.0,
         color: Colors.blue,
        )),
            onTap: () {
              Navigator.of(context)
                    .push(MaterialPageRoute(builder: (BuildContext context) {
                  return StudentProgressScreen();
                }));
            },
            trailing: Container(
              color: Colors.red,
              width: 20,
              height: 20,
              child: Center(
                child: Text(
                  '1',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
          Divider(),
         
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Exit', style: TextStyle(
          fontWeight: FontWeight.bold,
         fontSize:20.0,
         color: Colors.blue,
        )),
            onTap: () {
              Navigator.of(context)
                    .push(MaterialPageRoute(builder: (BuildContext context) {
                  return const Hall();
                }));
            },
          ),
        ],
      ),
    );
  }
}
