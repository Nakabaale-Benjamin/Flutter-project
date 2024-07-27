import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:halls/admin/hall_update.dart';
import 'package:halls/criteria_update.dart';
import "../widget/button.dart";
import "assignment.dart";

enum SideBarItem {
  dashboard,
  users,
  halls,
  criteria,
  logout;

  String get value {
    switch (this) {
      case SideBarItem.dashboard:
        return 'Dashboard';
      case SideBarItem.users:
        return 'Users';
      case SideBarItem.halls:
        return 'Halls';
      case SideBarItem.criteria:
        return 'Criteria';
      case SideBarItem.logout:
        return 'Logout';
    }
  }

  IconData get iconData {
    switch (this) {
      case SideBarItem.dashboard:
        return Icons.dashboard;
      case SideBarItem.users:
        return Icons.people;
      case SideBarItem.halls:
        return Icons.house;
      case SideBarItem.criteria:
        return Icons.settings;
      case SideBarItem.logout:
        return Icons.logout;
    }
  }

  Widget get body {
    switch (this) {
      case SideBarItem.dashboard:
        return DashboardScreen();
      case SideBarItem.users:
        return UsersScreen();
      case SideBarItem.halls:
        return HallsScreen();
      case SideBarItem.criteria:
        return CriteriaScreen();
      case SideBarItem.logout:
        return LogoutScreen();
    }
  }

  String get name {
    return this.toString().split('.').last;
  }
}

class SideBarNotifier extends StateNotifier<SideBarItem> {
  SideBarNotifier() : super(SideBarItem.dashboard);

  void selectPage(SideBarItem item) {
    state = item;
  }
}

final sideBarItemProvider =
    StateNotifierProvider<SideBarNotifier, SideBarItem>((ref) {
  return SideBarNotifier();
});

class AdminPanel extends ConsumerWidget {
  const AdminPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(sideBarItemProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      drawer: Drawer(
        child: CustomSidebar(
          currentPage: currentPage,
          onItemSelected: (item) {
            if (item == SideBarItem.logout) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LogoutScreen()),
              );
            } else {
              ref.read(sideBarItemProvider.notifier).selectPage(item);
              Navigator.of(context).pop(); // Close the drawer
            }
          },
        ),
      ),
      body: currentPage.body,
    );
  }
}

class CustomSidebar extends StatelessWidget {
  final SideBarItem currentPage;
  final void Function(SideBarItem) onItemSelected;

  const CustomSidebar({
    Key? key,
    required this.currentPage,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: SideBarItem.values.map((item) {
        final isSelected = currentPage == item;
        return ListTile(
          leading: Icon(item.iconData, color: isSelected ? Colors.green : Colors.black),
          title: Text(
            item.value,
            style: TextStyle(
              fontSize: 18, // Change this to your desired font size
              color: isSelected ? Colors.green : Colors.black, // Change this to your desired font color
            ),
          ),
          tileColor: isSelected ? Color.fromARGB(255, 199, 243, 203) : Colors.transparent,
          onTap: () => onItemSelected(item),
        );
      }).toList(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: MyButtons(
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return StudentAssignmentScreen();
              }));
            },
            text: "Assign Students Rooms "));
  }
}

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Users screen', style: TextStyle(fontSize: 24)),
    );
  }
}

class LogoutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future<void> _logout() async {
      try {
        await FirebaseAuth.instance.signOut();
        Navigator.of(context).pushReplacementNamed('/login');
      } catch (e) {
        print('Error during logout: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to logout')),
        );
      }
    }

    _logout();

    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
