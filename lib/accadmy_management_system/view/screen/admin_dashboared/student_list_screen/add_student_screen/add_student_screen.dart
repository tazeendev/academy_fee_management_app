import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../widget/form-feilds/text_form_feilds.dart';

class AddStudentScreen extends StatefulWidget {
  final String courseId;
  const AddStudentScreen({Key? key, required this.courseId}) : super(key: key);

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}
class _AddStudentScreenState extends State<AddStudentScreen> {
  final nameController = TextEditingController();
  final fatherNameController = TextEditingController();
  final introController = TextEditingController();
  final courseController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  bool isLoading = false;

  Future<void> saveStudent() async {
    if (nameController.text.isEmpty ||
        fatherNameController.text.isEmpty ||
        introController.text.isEmpty ||
        courseController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields", style: TextStyle(color: Colors.red))),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();

      await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('studentList')
          .doc(id)
          .set({
        'name': nameController.text,
        'fname': fatherNameController.text,
        'intro': introController.text,
        'course': courseController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'address': addressController.text,
        });

      Navigator.pop(context, true); // return success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding student: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Student",
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white)),
        backgroundColor: const Color(0xFF0D47A1),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomTextField(
              controller: nameController,
              hintText: 'Enter Name',
              labelText: 'Name',
              prefixIcon: Icons.account_circle_outlined,
              hintColor: Color(0xFF0D47A1),
              labelColor: Color(0xFF0D47A1),
            ),
            SizedBox(height: 12),
            CustomTextField(
              controller: fatherNameController,
              hintText: 'Enter Father Name',
              labelText: 'Father Name',
              prefixIcon: Icons.person,
              hintColor: Color(0xFF0D47A1),
              labelColor: Color(0xFF0D47A1),
            ),
            SizedBox(height: 12),
            CustomTextField(
              controller: introController,
              hintText: 'Student Intro',
              labelText: 'Introduction',
              prefixIcon: Icons.account_box_outlined,
              hintColor: Color(0xFF0D47A1),
              labelColor: Color(0xFF0D47A1),
            ),
            SizedBox(height: 12),
            CustomTextField(
              controller: courseController,
              hintText: 'Enter Course',
              labelText: 'Course',
              prefixIcon: Icons.description_outlined,
              hintColor: Color(0xFF0D47A1),
              labelColor: Color(0xFF0D47A1),
            ),
            SizedBox(height: 12),
            CustomTextField(
              controller: emailController,
              hintText: 'Enter Email',
              labelText: 'Email',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              hintColor: Color(0xFF0D47A1),
              labelColor: Color(0xFF0D47A1),
            ),
            SizedBox(height: 12),
            CustomTextField(
              controller: phoneController,
              hintText: 'Phone Number',
              labelText: 'Phone Number',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
              hintColor: Color(0xFF0D47A1),
              labelColor: Color(0xFF0D47A1),
            ),
            SizedBox(height: 12),
            CustomTextField(
              controller: addressController,
              hintText: 'Student Address',
              labelText: 'Address',
              prefixIcon: Icons.location_city,
              keyboardType: TextInputType.streetAddress,
              hintColor: Color(0xFF0D47A1),
              labelColor: Color(0xFF0D47A1),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: isLoading ? null : saveStudent,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 50,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isLoading
                        ? [Colors.blue.shade700, Colors.lightBlueAccent]
                        : [Colors.lightBlueAccent, Colors.blueAccent],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.5),
                        blurRadius: 12,
                        spreadRadius: 1,
                        offset: const Offset(0, 5))
                  ],
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('Save Student',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
