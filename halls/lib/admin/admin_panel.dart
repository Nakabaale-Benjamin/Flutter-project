import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'hall_update.dart';
import 'criteria_update.dart';

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

final sideBarItemProvider = StateNotifierProvider<SideBarNotifier, SideBarItem>((ref) {
  return SideBarNotifier();
});

class AdminPanel extends ConsumerWidget {
  const AdminPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(sideBarItemProvider);

    return AdminScaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      sideBar: SideBar(
        activeBackgroundColor: Color.fromARGB(255, 95, 173, 101),
        onSelected: (item) {
          if (item.route == SideBarItem.logout.name) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => LogoutScreen()),
            );
          } else {
            ref.read(sideBarItemProvider.notifier).selectPage(SideBarItem.values.firstWhere((e) => e.name == item.route));
          }
        },
        items: SideBarItem.values
            .map((e) => AdminMenuItem(
                  title: e.value,
                  icon: e.iconData,
                  route: e.name,
                ))
            .toList(),
        selectedRoute: currentPage.name,
      ),
      body: currentPage.body,
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Dashboard screen', style: TextStyle(fontSize: 24)),
    );
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
