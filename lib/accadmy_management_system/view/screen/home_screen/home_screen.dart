import 'package:firebase_app/accadmy_management_system/view/screen/admin_dashboared/courses_screen/course_screen.dart';
import 'package:firebase_app/accadmy_management_system/view/screen/admin_dashboared/fee_details_screen/fee_details_screen.dart';
import 'package:firebase_app/accadmy_management_system/view/screen/admin_dashboared/student_list_screen/student_screen.dart';
import 'package:flutter/material.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  final PageController pageController = PageController();

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipPath(
                clipper: RoundedBottomClipper(),
                child: Container(height: 200, color: Color(0xFF0D47A1)),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 40),
                child: Row(
                  children: [
                    Text(
                      'Fee Mangament ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                bottom: -60,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: 150,
                  child: PageView(
                    controller: pageController,
                    children: [
                      BannerCard('assets/images/banner1.jpeg', 'Announcements'),
                      BannerCard('assets/images/banner2.jpeg', 'Events'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 80),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8,
              ),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  buildCard(Icons.book, 'Syllabus',CoursesScreen()),
                  buildCard(Icons.calendar_today, 'Attendance',StudentsScreen()),
                  buildCard(Icons.bar_chart, 'Result',FeeScreen()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCard(IconData icon, String label,Widget navigate) {
    return GestureDetector(
      onTap: (){
        Navigator.push(context,MaterialPageRoute(builder: (context)=>navigate));},
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: const Color(0xFFE3F2FD),
              child: Icon(icon, color: const Color(0xFF0D47A1), size: 30),
            ),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// Banner card widget
class BannerCard extends StatelessWidget {
  final String image;
  final String title;

  const BannerCard(this.image, this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image, height: 60, width: 60),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class RoundedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double radius = 30;
    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, size.height - radius);
    path.quadraticBezierTo(0, size.height, radius, size.height);
    path.lineTo(size.width - radius, size.height);
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width,
      size.height - radius,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
