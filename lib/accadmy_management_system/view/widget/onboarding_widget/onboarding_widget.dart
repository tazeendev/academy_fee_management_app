import 'package:flutter/material.dart';
class OnboardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String des;
  const OnboardingPage({
    super.key,
    required this.image,
    required this.title,
    required this.des,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image, height: 250),
           SizedBox(height: 30),
          Text(
            title,
            style:  TextStyle(
              fontSize: 26,
              color: Color(0xFF0D47A1),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
           SizedBox(height: 15),
          Text(
            des,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500
            ),
          ),
        ],
      ),
    );
  }
}
