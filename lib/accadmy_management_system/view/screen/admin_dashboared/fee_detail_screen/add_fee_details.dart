import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../widget/form-feilds/text_form_feilds.dart';
class AddFeeScreen extends StatefulWidget {
  final String courseId;
  final String studentId;
  const AddFeeScreen({super.key, required this.courseId, required this.studentId});
  @override
  State<AddFeeScreen> createState() => _AddFeeScreenState();
}
class _AddFeeScreenState extends State<AddFeeScreen> {
  final _firestore = FirebaseFirestore.instance;
  final amountController = TextEditingController();
  DateTime? selectedDate;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Fee",
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue.shade800,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CustomTextField(
                controller: nameController,
                hintText: 'Course Name',
                prefixIcon: Icons.book),
            const SizedBox(height: 12),
            CustomTextField(
                controller: descController,
                hintText: 'Description',
                prefixIcon: Icons.description),
            const SizedBox(height: 12),
            CustomTextField(
                controller: feeController,
                hintText: 'Fee',
                prefixIcon: Icons.attach_money,
                keyboardType: TextInputType.number),
            const SizedBox(height: 25),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))),
              onPressed: _saveFee,
              child: Text("Save Fee",
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _saveFee() async {
    if (nameController.text.isEmpty ||
        descController.text.isEmpty ||
        feeController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => isLoading = true);

    try {
      await _firestore
          .collection('courses')
          .doc(widget.courseId)
          .collection('studentList')
          .doc(widget.studentId)
          .collection('feeDetail')
          .add({
        'name': nameController.text,
        'description': descController.text,
        'fee': double.tryParse(feeController.text) ?? 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }
}
