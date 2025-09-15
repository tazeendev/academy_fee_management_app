import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class FeePaymentScreen extends StatefulWidget {
  final Map<String, dynamic> course;
  final String userId;

  const FeePaymentScreen({
    required this.course,
    required this.userId,
    super.key,
  });

  @override
  State<FeePaymentScreen> createState() => _FeePaymentScreenState();
}

class _FeePaymentScreenState extends State<FeePaymentScreen> {
  bool isPaying = false;

  Future<void> payFee() async {
    setState(() => isPaying = true);
    try {
      final courseId = widget.course['id'];
      final userId = widget.userId;

      // 1️⃣ Update fee document in student's collection
      final feeDocs = await FirebaseFirestore.instance
          .collection('students')
          .doc(userId)
          .collection('fees')
          .where('courseId', isEqualTo: courseId)
          .get();

      for (var doc in feeDocs.docs) {
        await doc.reference.update({'status': 'paid'});
      }

      // 2️⃣ Update student's paid status in course collection
      await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .collection('students')
          .doc(userId)
          .update({'paid': true});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment Successful!")),
      );

      Navigator.pop(context); // Go back to courses screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment failed: $e")),
      );
    } finally {
      setState(() => isPaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseName = widget.course['name'] ?? '';
    final feeAmount = widget.course['fee']?.toDouble() ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Fee Payment"),
        backgroundColor: Color(0xFF0D47A1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Course:", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 5),
            Text(courseName, style: GoogleFonts.poppins(fontSize: 20)),
            const SizedBox(height: 20),
            Text("Fee:", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 5),
            Text("PKR ${feeAmount.toStringAsFixed(2)}", style: GoogleFonts.poppins(fontSize: 20, color: Colors.green.shade700)),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: isPaying ? null : payFee,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isPaying
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text("Pay Now", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
