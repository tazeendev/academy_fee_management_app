import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CourseDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> course;
  const CourseDetailsScreen({Key? key, required this.course}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          course['name'],
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
        ),
        backgroundColor: Color(0xFF0D47A1),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course['name'],
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 22),
                ),
                const SizedBox(height: 10),
                Text(
                  "Fee: PKR ${course['fee'].toStringAsFixed(2)}",
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 20),
                Text(
                  course['description'],
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
