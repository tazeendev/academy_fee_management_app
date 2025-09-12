import 'package:firebase_app/accadmy_management_system/view/screen/auth_screens/login_screen/login_screen.dart';
import 'package:firebase_app/accadmy_management_system/view/screen/nav/nav_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../onboarding_screen/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  final String courseId;
  final String studentId;
  const SplashScreen({super.key, required this.courseId, required this.studentId});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      if (FirebaseAuth.instance.currentUser == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context)
          =>
              OnboardingScreen(courseId: widget.courseId,studentId: widget.studentId,)),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) =>
              NavScreen(Id1: widget.courseId, Id2:widget.studentId)),
        );
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/splash.jpeg',fit: BoxFit.cover, width: 150, height: 150),
            SizedBox(height: 20),
            Text(
              'Welcome to My App',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,color: Color(0xFF0D47A1)),
            ),
          ],
        ),
      ),
    );
  }
}
