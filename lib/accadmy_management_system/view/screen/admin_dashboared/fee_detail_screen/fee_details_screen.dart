import 'package:firebase_app/accadmy_management_system/view/widget/form-feilds/text_form_feilds.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:folding_cell/folding_cell.dart';

class FeeDetailsScreen extends StatefulWidget {
  final String courseId;
  final String studentId;

  const FeeDetailsScreen({
    Key? key,
    required this.courseId,
    required this.studentId,
  }) : super(key: key);

  @override
  State<FeeDetailsScreen> createState() => _FeeDetailsScreenState();
}

class _FeeDetailsScreenState extends State<FeeDetailsScreen> {
  final _firestore = FirebaseFirestore.instance;
  final List<GlobalKey<SimpleFoldingCellState>> cellKeys = [];

  @override
  Widget build(BuildContext context) {
    // Defensive check for null or empty IDs
    if (widget.courseId.isEmpty || widget.studentId.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Fee Details"),
        ),
        body: const Center(
          child: Text("Invalid course or student ID"),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Fee Details",
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, color: Colors.white, fontSize: 24),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade800,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('courses')
            .doc(widget.courseId)
            .collection('studentList')
            .doc(widget.studentId)
            .collection('feeDetail')
            .orderBy('dueDate')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading fee details"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final feeDocs = snapshot.data?.docs ?? [];

          if (feeDocs.isEmpty) {
            return const Center(child: Text("No Fee Records Found"));
          }

          // Ensure cellKeys list matches documents length
          while (cellKeys.length < feeDocs.length) {
            cellKeys.add(GlobalKey<SimpleFoldingCellState>());
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: feeDocs.length,
            itemBuilder: (context, index) {
              final doc = feeDocs[index];
              final data = doc.data() as Map<String, dynamic>? ?? {};
              if (doc.id.isEmpty) return const SizedBox.shrink(); // Defensive check

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SimpleFoldingCell.create(
                  key: cellKeys[index],
                  frontWidget: _buildFrontCard(doc.id, data, index),
                  innerWidget: _buildInnerCard(doc.id, data, index),
                  cellSize: Size(MediaQuery.of(context).size.width, 150),
                  padding: EdgeInsets.zero,
                  animationDuration: const Duration(milliseconds: 300),
                  borderRadius: 15,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFrontCard(String id, Map<String, dynamic> data, int index) {
    final double amount = (data['amount'] ?? 0).toDouble();
    final Timestamp? ts = data['dueDate'] as Timestamp?;
    final DateTime dueDate = ts?.toDate() ?? DateTime.now();
    final String status = data['status'] ?? 'Pending';

    Color statusColor;
    if (status.toLowerCase() == "paid") {
      statusColor = Colors.green;
    } else if (status.toLowerCase() == "pending" && dueDate.isBefore(DateTime.now())) {
      statusColor = Colors.red;
    } else {
      statusColor = Colors.orange;
    }

    return GestureDetector(
      onTap: () => cellKeys[index].currentState?.toggleFold(),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 4)),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("PKR ${amount.toStringAsFixed(2)}",
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            Text("Due: ${dueDate.day}-${dueDate.month}-${dueDate.year}",
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(12)),
              child: Text(status,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInnerCard(String id, Map<String, dynamic> data, int index) {
    final double amount = (data['amount'] ?? 0).toDouble();
    final Timestamp? ts = data['dueDate'] as Timestamp?;
    final DateTime dueDate = ts?.toDate() ?? DateTime.now();
    final String status = data['status'] ?? 'Pending';

    return GestureDetector(
      onTap: () => cellKeys[index].currentState?.toggleFold(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Amount: PKR ${amount.toStringAsFixed(2)}",
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 6),
          Text("Due Date: ${dueDate.day}-${dueDate.month}-${dueDate.year}",
              style: GoogleFonts.poppins(fontSize: 14)),
          const SizedBox(height: 6),
          Text("Status: $status", style: GoogleFonts.poppins(fontSize: 14)),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800),
              onPressed: () => _showOptions(context, id, data),
              icon: const Icon(Icons.edit, size: 18),
              label: const Text("Options"),
            ),
          )
        ]),
      ),
    );
  }

  void _showOptions(BuildContext context, String id, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Choose Action"),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                showUpdateDialog(context, id, data);
              },
              child: const Text("Update")),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                showDeleteDialog(context, id);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  void showUpdateDialog(BuildContext context, String id, Map<String, dynamic> data) {
    final amountController = TextEditingController(text: data['amount']?.toString() ?? '0');
    DateTime selectedDate = (data['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now();
    String status = data['status'] ?? 'Pending';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text("Update Fee"),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            CustomTextField(
              controller: amountController,
              hintText: "Amount",
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100));
                if (pickedDate != null) {
                  setStateDialog(() => selectedDate = pickedDate);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${selectedDate.day}-${selectedDate.month}-${selectedDate.year}"),
                    const Icon(Icons.calendar_today, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: status,
              items: ["Paid", "Pending"].map((s) {
                return DropdownMenuItem(value: s, child: Text(s));
              }).toList(),
              onChanged: (val) => setStateDialog(() => status = val!),
              decoration: const InputDecoration(labelText: "Status"),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                if (widget.courseId.isEmpty || widget.studentId.isEmpty) return;

                await _firestore
                    .collection('courses')
                    .doc(widget.courseId)
                    .collection('studentList')
                    .doc(widget.studentId)
                    .collection('feeDetail')
                    .doc(id)
                    .update({
                  'amount': double.tryParse(amountController.text) ?? data['amount'],
                  'dueDate': selectedDate,
                  'status': status,
                });
                Navigator.pop(context);
              },
              child: const Text("Update"),
            ),
          ],
        ),
      ),
    );
  }

  void showDeleteDialog(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Fee Record"),
        content: const Text("Are you sure you want to delete this record?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                if (widget.courseId.isEmpty || widget.studentId.isEmpty) return;

                await _firestore
                    .collection('courses')
                    .doc(widget.courseId)
                    .collection('studentList')
                    .doc(widget.studentId)
                    .collection('feeDetail')
                    .doc(id)
                    .delete();
                Navigator.pop(context);
              },
              child: const Text("Delete")),
        ],
      ),
    );
  }
}
