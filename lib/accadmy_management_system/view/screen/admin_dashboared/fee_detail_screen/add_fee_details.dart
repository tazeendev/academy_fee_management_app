import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../widget/form-feilds/text_form_feilds.dart';

class AddFeeScreen extends StatefulWidget {
  final String courseId;
  final String studentId;
  const AddFeeScreen({
    super.key,
    required this.courseId,
    required this.studentId,
  });

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              controller: amountController,
              hintText: 'Enter the money',
              prefixIcon: Icons.attach_money,
              hintColor: const Color(0xFF0D47A1),
              labelColor: const Color(0xFF0D47A1),
              labelText: 'Fee Amount',
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                    child: Text(selectedDate == null
                        ? 'No Date selected'
                        : 'Due Date: ${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}')),
                IconButton(
                  onPressed: () async {
                    final pickDate = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      initialDate: DateTime.now(),
                    );
                    if (pickDate != null) {
                      setState(() {
                        selectedDate = pickDate;
                      });
                    }
                  },
                  icon: const Icon(Icons.calendar_today),
                ),
              ],
            ),
            SizedBox(height: 40),
            GestureDetector(
              onTap: () async {
                try {
                  setState(() {
                    isLoading = true;
                  });

                  if (amountController.text.isEmpty || selectedDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Please enter amount and due date")));
                    return;
                  }
                  final feeId = DateTime.now().millisecondsSinceEpoch.toString();

                  await _firestore
                      .collection('courses')
                      .doc(widget.courseId)
                      .collection('studentList')
                      .doc(widget.studentId)
                      .collection('feeDetail')
                      .doc(feeId)
                      .set({
                    'amount': double.tryParse(amountController.text) ?? 0,
                    'status': 'Pending',
                    'dueDate': selectedDate,
                    });


                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error saving fee: $e")));
                } finally {
                  setState(() => isLoading = false);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Colors.blue, Colors.lightBlueAccent]),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.blue.withOpacity(0.4),
                          blurRadius: 7,
                          offset: const Offset(0, 5))
                    ]),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                  "Save Fee",
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
