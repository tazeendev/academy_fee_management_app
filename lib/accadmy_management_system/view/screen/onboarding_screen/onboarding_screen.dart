import 'package:firebase_app/accadmy_management_system/view/screen/auth_screens/signup_screen/signup_screen.dart';
import 'package:firebase_app/accadmy_management_system/view/widget/onboarding_widget/onboarding_widget.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../auth_screens/login_screen/login_screen.dart';
class OnboardingScreen extends StatefulWidget {
  // final String courseId;
  // final String studentId;
  const OnboardingScreen({super.key, });
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}
class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController controller = PageController();
  bool isLastPage = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: controller,
              onPageChanged: (index) {
                setState(() => isLastPage = index == 2);
              },
              children: const [
                OnboardingPage(
                  image: 'assets/images/pic1.jpeg',
                  title: 'Welcome to Academy Fee Manager',
                  des:
                  'A smarter way to manage your academy’s student fees and records',
                ),
                OnboardingPage(
                  image: 'assets/images/pic2.jpeg',
                  title: 'Track Fees Easily',
                  des:
                  'Keep fee records organized with just a few taps — no paperwork, no stress',
                ),
                OnboardingPage(
                  image: 'assets/images/pic3.jpeg',
                  title: 'Stay Organized & Save Time',
                  des:
                  'Focus on learning while we handle your fee management seamlessly',
                ),
              ],
            ),
          ),
          Padding(
            padding:EdgeInsets.all(16.0),
            child: Column(
              children: [
                SmoothPageIndicator(
                  controller: controller,
                  count: 3,
                  effect: const ExpandingDotsEffect(
                    activeDotColor: Color(0xFF0D47A1),
                    dotHeight: 10,
                    dotWidth: 10,
                  ),
                ),
                 SizedBox(height: 20),
                if (isLastPage)
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder:
                            (context)=>SignupScreen()));
                        print("Get Started Clicked");
                        // Navigate to dashboard/login here
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "Get Started",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  )
                else
                // Skip + Next row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Skip Button
                      GestureDetector(
                        onTap: () {
                          controller.jumpToPage(2);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "Skip",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          controller.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 10),
                          decoration: BoxDecoration(
                            color:Color(0xFF0D47A1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "Next",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
