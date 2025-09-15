import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../fee_payment_screen/fee_payment_screen.dart';
import 'course_details/course_details.dart';
class UserCoursesScreen extends StatefulWidget {
  const UserCoursesScreen({Key? key}) : super(key: key);

  @override
  State<UserCoursesScreen> createState() => _UserCoursesScreenState();
}

class _UserCoursesScreenState extends State<UserCoursesScreen> {
  final _firestore = FirebaseFirestore.instance;
  bool isLoading = true;
  List<Map<String, dynamic>> courses = [];

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  Future<void> fetchCourses() async {
    try {
      final snapshot = await _firestore.collection('courses').get();
      final fetchedCourses = snapshot.docs
          .map((doc) => {
        'id': doc.id,
        'name': doc['name'] ?? '',
        'description': doc['description'] ?? '',
        'fee': doc['fee']?.toDouble() ?? 0.0,
      })
          .toList();
      setState(() {
        courses = fetchedCourses;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching courses: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Courses",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF0D47A1),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : courses.isEmpty
          ? const Center(child: Text("No Courses Available"))
          : ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course['name'],
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    course['description'],
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Fee: PKR ${course['fee'].toStringAsFixed(2)}",
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0D47A1),
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        // Navigate to fee/payment screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FeePaymentScreen(
                              course: course, userId: '',
                            ),
                          ),
                        );
                      },
                      child: Text(
                        "Enroll Now →",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
