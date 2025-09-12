import 'package:firebase_app/accadmy_management_system/view/widget/form-feilds/text_form_feilds.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateCourseScreen extends StatefulWidget {
  const CreateCourseScreen({super.key});

  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  final _firestore = FirebaseFirestore.instance;
  final nameController = TextEditingController();
  final descController = TextEditingController();
  final feeController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Create Course",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CustomTextField(
              controller: nameController,
              hintText: 'Course Name',
              prefixIcon: Icons.book,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: descController,
              hintText: 'Description',
              prefixIcon: Icons.description,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: feeController,
              hintText: 'Fee',
              prefixIcon: Icons.attach_money,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 30),

            // Save Button
            GestureDetector(
              onTap: () async {
                if (nameController.text.isEmpty ||
                    descController.text.isEmpty ||
                    feeController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please fill all fields")),
                  );
                  return;
                }

                setState(() => isLoading = true);

                final id = DateTime.now().millisecondsSinceEpoch.toString();
                try {
                  await _firestore.collection("courses").doc(id).set({
                    "name": nameController.text,
                    "description": descController.text,
                    "fee": double.tryParse(feeController.text) ?? 0,
                  });

                  setState(() => isLoading = false);

                  Navigator.pop(context); // Go back to courses list
                } catch (e) {
                  setState(() => isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: $e")),
                  );
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
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
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                  "Save Course",
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
  }
}
