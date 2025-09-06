import 'package:flutter/material.dart';

import '../admin_dashboared/admin_dashboared.dart';
import '../admin_dashboared/course_screen.dart';
import '../admin_dashboared/student_screen.dart';

class AdminNavScreen extends StatefulWidget {
  const AdminNavScreen({Key? key}) : super(key: key);

  @override
  State<AdminNavScreen> createState() => _AdminNavScreenState();
}

class _AdminNavScreenState extends State<AdminNavScreen> {
  int currentIndex = 0;

  // Screens
  final List<Widget> _screens = [
    FeeManagementScreen(),
    CoursesScreen(),
    StudentsScreen(),
  ];

  // Titles for AppBar
  final List<String> _titles = [
    'Fee Management',
    'Courses',
    'Students',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[currentIndex],
          style: TextStyle(
            color: theme.appBarTheme.foregroundColor ?? theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface,
        elevation: 0,
      ),
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
        backgroundColor: theme.bottomNavigationBarTheme.backgroundColor ??
            theme.colorScheme.surface,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'Fees',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Students',
          ),
        ],
      ),
    );
  }
}
