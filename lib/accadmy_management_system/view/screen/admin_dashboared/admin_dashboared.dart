import 'package:flutter/material.dart';
import 'package:folding_cell/folding_cell/widget.dart';
import '../../../model/admin_model/admin_model.dart';
import '../../../services/admin_dashboared_service/admin_dashboared_service.dart';
class FeeManagementScreen extends StatelessWidget {
  FeeManagementScreen({Key? key}) : super(key: key);
  final AdminServiceData _service = AdminServiceData();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fee Management'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),

      // ✅ FAB for creating new fee
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateFeeDialog(context),
        child: const Icon(Icons.add),
      ),

      body: StreamBuilder<List<Fee>>(
        stream: _service.getFees(),
        builder: (context, feeSnapshot) {
          if (!feeSnapshot.hasData) return const Center(child: CircularProgressIndicator());
          final fees = feeSnapshot.data!;
          if (fees.isEmpty) return const Center(child: Text('No fees found.'));

          return StreamBuilder<List<Student>>(
            stream: _service.getStudents(),
            builder: (context, studentSnapshot) {
              if (!studentSnapshot.hasData) return const Center(child: CircularProgressIndicator());
              final students = studentSnapshot.data!;

              return StreamBuilder<List<Course>>(
                stream: _service.getCourses(),
                builder: (context, courseSnapshot) {
                  if (!courseSnapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final courses = courseSnapshot.data!;

                  return ListView.builder(
                    itemCount: fees.length,
                    itemBuilder: (context, index) {
                      final fee = fees[index];
                      final student = students.firstWhere(
                            (s) => s.id == fee.studentId,
                        orElse: () => Student(id: '', name: 'Unknown', courseId: '', contact: ''),
                      );
                      final course = courses.firstWhere(
                            (c) => c.id == student.courseId,
                        orElse: () => Course(id: '', name: 'Unknown', description: '', fee: 0),
                      );

                      final isOverdue = fee.dueDate.isBefore(DateTime.now());
                      final cellKey = GlobalKey<SimpleFoldingCellState>();

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: SimpleFoldingCell.create(
                          key: cellKey,
                          frontWidget: GestureDetector(
                            onTap: () => cellKey.currentState?.toggleFold(),
                            child: Container(
                              height: 150,
                              decoration: BoxDecoration(
                                color: isOverdue ? Colors.red.shade200 : Colors.green.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: Colors.orange,
                                    child: Text(student.name.isNotEmpty ? student.name[0] : '?',
                                        style: const TextStyle(color: Colors.white)),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        Text(course.name, style: const TextStyle(color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('PKR ${fee.amount.toStringAsFixed(2)}'),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isOverdue ? Colors.red : Colors.green,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '${fee.dueDate.day}/${fee.dueDate.month}/${fee.dueDate.year}',
                                          style: const TextStyle(color: Colors.white, fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          innerWidget: Container(
                            height: 350,
                            decoration: BoxDecoration(
                              color: isOverdue ? Colors.red.shade100 : Colors.green.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Full Details', style: TextStyle(fontWeight: FontWeight.bold)),
                                  const Divider(),
                                  const Text("👤 Student Info", style: TextStyle(fontWeight: FontWeight.w600)),
                                  Text('Name: ${student.name}'),
                                  Text('Contact: ${student.contact}'),
                                  Text('Student ID: ${student.id}'),
                                  const SizedBox(height: 8),

                                  const Text("📘 Course Info", style: TextStyle(fontWeight: FontWeight.w600)),
                                  Text('Course: ${course.name}'),
                                  Text('Description: ${course.description}'),
                                  Text('Course Fee: PKR ${course.fee}'),
                                  const SizedBox(height: 8),

                                  const Text("💰 Fee Info", style: TextStyle(fontWeight: FontWeight.w600)),
                                  Text('Amount Paid: PKR ${fee.amount.toStringAsFixed(2)}'),
                                  Text('Status: ${fee.status}'),
                                  Text('Due Date: ${fee.dueDate.day}/${fee.dueDate.month}/${fee.dueDate.year}'),

                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          // TODO: Update screen
                                        },
                                        child: const Text('Update'),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                        onPressed: () async {
                                          await _service.deleteFee(fee.id);
                                        },
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                          cellSize: Size(MediaQuery.of(context).size.width, 150),
                          padding: const EdgeInsets.all(0),
                          animationDuration: const Duration(milliseconds: 400),
                          borderRadius: 12,
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // ✅ Create Fee Dialog
  void _showCreateFeeDialog(BuildContext context) async {
    final amountController = TextEditingController();
    final statusController = TextEditingController();
    DateTime? selectedDate;

    // Fetch students and courses for dropdowns
    final students = await _service.getStudents().first;
    final courses = await _service.getCourses().first;

    Student? selectedStudent;
    Course? selectedCourse;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add New Fee'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  DropdownButtonFormField<Student>(
                    value: selectedStudent,
                    items: students.map((s) {
                      return DropdownMenuItem(
                        value: s,
                        child: Text(s.name),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => selectedStudent = val),
                    decoration: const InputDecoration(labelText: "Select Student"),
                  ),
                  DropdownButtonFormField<Course>(
                    value: selectedCourse,
                    items: courses.map((c) {
                      return DropdownMenuItem(
                        value: c,
                        child: Text(c.name),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => selectedCourse = val),
                    decoration: const InputDecoration(labelText: "Select Course"),
                  ),
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(labelText: 'Amount'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: statusController,
                    decoration: const InputDecoration(labelText: 'Status'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() => selectedDate = pickedDate);
                      }
                    },
                    child: Text(selectedDate == null
                        ? "Pick Due Date"
                        : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
              ElevatedButton(
                onPressed: () async {
                  if (selectedStudent != null && selectedCourse != null && selectedDate != null) {
                    final newFee = Fee(
                      id: '', // Firestore will generate
                      studentId: selectedStudent!.id,
                      courseId: selectedCourse!.id,
                      amount: double.tryParse(amountController.text) ?? 0,
                      dueDate: selectedDate!,
                      status: statusController.text,
                    );
                    await _service.addFee(newFee);
                    Navigator.pop(context);
                  }
                },
                child: const Text("Add Fee"),
              )
            ],
          );
        },
      ),
    );
  }
}
