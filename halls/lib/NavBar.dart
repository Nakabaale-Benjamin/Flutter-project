import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:halls/hall.dart';
import 'package:halls/profile.dart';


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
          UserAccountsDrawerHeader(
            accountName: Text('Kasakya Denis Nicholas'), 
            accountEmail: Text('kdnicholas9@gmail.com'),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: Image.asset(
                  "assets/images/studentprofile.png",
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.black,
              image: DecorationImage(
                image: AssetImage(
                 "                     ",
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ListTile(
  leading: Icon(Icons.person),
  title: Text('Profile'),
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
            title: Text('Notifications'),
            onTap: () => null,
            trailing: Container(
              color: Colors.red,
              width: 20,
              height: 20,
              child: Center(
                child: Text(
                  '5',
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
            title: Text('Exit'),
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
