import 'package:flutter/material.dart';
import '../admin_dashboared/courses_screen/course_screen.dart';
import '../admin_dashboared/fee_details_screen/fee_details_screen.dart';
import '../admin_dashboared/student_list_screen/student_screen.dart';
class NavScreen extends StatefulWidget {
  const NavScreen({Key? key});
  @override
  State<NavScreen> createState() => _NavScreenState();
}
class _NavScreenState extends State<NavScreen> {
  int currentIndex = 0;
  final List<Widget> screens = [
    CoursesScreen(),
    StudentsScreen(),
    FeeScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.blue,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items:  [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Students',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'Fees',
          ),
        ],
      ),
    );
  }
}
