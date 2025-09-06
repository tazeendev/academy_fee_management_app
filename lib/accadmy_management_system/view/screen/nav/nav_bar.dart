
import 'package:flutter/cupertino.dart';
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
    CoursesScreen(),
    StudentsScreen(),
    FeeManagementScreen(),
  ];

  // Titles for AppBar
  final List<String> _titles = [
    'Fee Management',
    'Courses',
    'Students',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[currentIndex]),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.blue.shade700,
        unselectedItemColor: Colors.grey,
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
