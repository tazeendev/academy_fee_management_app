import 'package:flutter/material.dart';
import '../admin_dashboared/courses_screen/add_course/add_course.dart';
import '../admin_dashboared/courses_screen/course_screen.dart';
import '../admin_dashboared/fee_detail_screen/add_fee_details.dart';
import '../admin_dashboared/student_list_screen/add_student_screen/add_student_screen.dart';
import '../admin_dashboared/student_list_screen/student_screen.dart';
import '../home_screen/home_screen.dart';

class NavScreen extends StatefulWidget {
  final String Id1;
  final String Id2;

  const NavScreen({Key? key, required this.Id1, required this.Id2})
      : super(key: key);

  @override
  State<NavScreen> createState() => _NavScreenState();
}

class _NavScreenState extends State<NavScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      StudentDashboardScreen(courseId: widget.Id1),
      CreateCourseScreen(),
      AddStudentScreen(courseId: widget.Id1,),
      AddFeeScreen(courseId: widget.Id1, studentId: widget.Id2),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: const Color(0xFF0D47A1),
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
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
