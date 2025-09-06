import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:folding_cell/folding_cell/widget.dart';
import 'package:google_fonts/google_fonts.dart';
class FeeScreen extends StatefulWidget {
  const FeeScreen({super.key});
  @override
  State<FeeScreen> createState() => _FeeScreenState();
}

class _FeeScreenState extends State<FeeScreen> {
  final CollectionReference feesRef = FirebaseFirestore.instance.collection('fees');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fee Management', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blue.shade800,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: feesRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final fees = snapshot.data!.docs;

          if (fees.isEmpty) return const Center(child: Text('No fees found.'));

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: fees.length,
            itemBuilder: (context, index) {
              final feeDoc = fees[index];
              final feeData = feeDoc.data() as Map<String, dynamic>;
              return FeeItem(
                key: Key(feeDoc.id),
                data: feeData,
                feeId: feeDoc.id,
                feesRef: feesRef,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.shade800,
        child: const Icon(Icons.add),
        onPressed: () => _showCreateFeeDialog(context),
      ),
    );
  }

  void _showCreateFeeDialog(BuildContext context) {
    final studentController = TextEditingController();
    final amountController = TextEditingController();
    final statusController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Fee'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: studentController, decoration: const InputDecoration(labelText: 'Student Name')),
            TextField(controller: amountController, decoration: const InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.number),
            TextField(controller: statusController, decoration: const InputDecoration(labelText: 'Status')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await feesRef.add({
                'studentName': studentController.text,
                'amount': double.tryParse(amountController.text) ?? 0,
                'status': statusController.text,
                'dueDate': Timestamp.now(),
              });
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class FeeItem extends StatefulWidget {
  final Map<String, dynamic> data;
  final String feeId;
  final CollectionReference feesRef;

  const FeeItem({
    required this.data,
    required this.feeId,
    required this.feesRef,
    super.key,
  });

  @override
  State<FeeItem> createState() => _FeeItemState();
}

class _FeeItemState extends State<FeeItem> {
  final GlobalKey<SimpleFoldingCellState> cellKey = GlobalKey<SimpleFoldingCellState>();

  @override
  Widget build(BuildContext context) {
    final dueDate = (widget.data['dueDate'] as Timestamp).toDate();
    final isOverdue = dueDate.isBefore(DateTime.now());
    final frontColor = isOverdue ? Colors.red.shade300 : Colors.green.shade300;
    final innerColor = isOverdue ? Colors.red.shade100 : Colors.green.shade100;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
      child: SimpleFoldingCell.create(
        key: cellKey,
        frontWidget: GestureDetector(
          onTap: () => cellKey.currentState?.toggleFold(),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: frontColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5, offset: const Offset(0, 3))],
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.data['studentName'] ?? 'Unknown', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('PKR ${widget.data['amount']}', style: GoogleFonts.poppins(fontSize: 16)),
              ],
            ),
          ),
        ),
        innerWidget: Container(
          height: 180,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: innerColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5, offset: const Offset(0,3))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Fee Details', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
              const Divider(),
              Text('Student: ${widget.data['studentName']}', style: GoogleFonts.poppins(fontSize: 14)),
              Text('Amount: PKR ${widget.data['amount']}', style: GoogleFonts.poppins(fontSize: 14)),
              Text('Status: ${widget.data['status'] ?? 'Pending'}', style: GoogleFonts.poppins(fontSize: 14)),
              Text('Due: ${dueDate.day}/${dueDate.month}/${dueDate.year}', style: GoogleFonts.poppins(fontSize: 14)),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(onPressed: () => _showUpdateFeeDialog(context), child: const Text('Update')),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () => widget.feesRef.doc(widget.feeId).delete(),
                    child:  Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        ),
        cellSize: Size(MediaQuery.of(context).size.width, 120),
        padding: const EdgeInsets.all(0),
        animationDuration: const Duration(milliseconds: 300),
        borderRadius: 12,
      ),
    );
  }

  void _showUpdateFeeDialog(BuildContext context) {
    final studentController = TextEditingController(text: widget.data['studentName']);
    final amountController = TextEditingController(text: widget.data['amount'].toString());
    final statusController = TextEditingController(text: widget.data['status']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Update Fee'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: studentController, decoration: const InputDecoration(labelText: 'Student Name')),
            TextField(controller: amountController, decoration: const InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.number),
            TextField(controller: statusController, decoration: const InputDecoration(labelText: 'Status')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              widget.feesRef.doc(widget.feeId).update({
                'studentName': studentController.text,
                'amount': double.tryParse(amountController.text) ?? 0,
                'status': statusController.text,
              });
              Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }
}
