import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:folding_cell/folding_cell.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({Key? key}) : super(key: key);

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}
class _CoursesScreenState extends State<CoursesScreen> {
  final _firestore = FirebaseFirestore.instance;
  final List<GlobalKey<SimpleFoldingCellState>> cellKeys = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Courses",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 28,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade800,
        elevation: 2,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('courses').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading courses"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final courses = snapshot.data!.docs;
          if (courses.isEmpty) {
            return const Center(child: Text("No Courses Found"));
          }

          // Ensure a key for each card
          while (cellKeys.length < courses.length) {
            cellKeys.add(GlobalKey<SimpleFoldingCellState>());
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final doc = courses[index];
              final data = doc.data() as Map<String, dynamic>;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SimpleFoldingCell.create(
                  key: cellKeys[index],
                  frontWidget: _buildFrontCard(data, index),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.shade800,
        onPressed: showAddDialog,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  // FRONT CARD
  Widget _buildFrontCard(Map<String, dynamic> data, int index) {
    return GestureDetector(
      onTap: () => cellKeys[index].currentState?.toggleFold(),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.blue.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                data['name'] ?? 'Course',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              "PKR ${data['fee']?.toStringAsFixed(2) ?? '0.00'}",
              style: GoogleFonts.poppins(
                color: Colors.green.shade200,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // INNER CARD
  Widget _buildInnerCard(String id, Map<String, dynamic> data, int index) {
    return GestureDetector(
      onTap: () => cellKeys[index].currentState?.toggleFold(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data['name'] ?? '',
              style:
              GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              data['description'] ?? '',
              style: GoogleFonts.poppins(fontSize: 15),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: () => _showOptions(id, data),
                icon: const Icon(Icons.edit, size: 18),
                label: const Text("Options"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- ADD COURSE ----------------
  void showAddDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final feeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Course"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Course Name"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: "Description"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: feeController,
                decoration: const InputDecoration(labelText: "Fee"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  descController.text.isEmpty ||
                  feeController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please fill all fields")));
                return;
              }
              await _firestore.collection('courses').add({
                'name': nameController.text,
                'description': descController.text,
                'fee': double.tryParse(feeController.text) ?? 0,
              });
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  // ---------------- UPDATE & DELETE ----------------
  void _showOptions(String id, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text("Choose Action"),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              showUpdateDialog(id, data);
            },
            child: const Text("Update"),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              showDeleteDialog(id, data['name']);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void showUpdateDialog(String id, Map<String, dynamic> data) {
    final nameController = TextEditingController(text: data['name']);
    final descController = TextEditingController(text: data['description']);
    final feeController =
    TextEditingController(text: data['fee']?.toString() ?? '0');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Update Course"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: "Course Name")),
              const SizedBox(height: 10),
              TextField(controller: descController, decoration: const InputDecoration(labelText: "Description")),
              const SizedBox(height: 10),
              TextField(controller: feeController, decoration: const InputDecoration(labelText: "Fee"), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await _firestore.collection('courses').doc(id).update({
                'name': nameController.text,
                'description': descController.text,
                'fee': double.tryParse(feeController.text) ?? data['fee'],
              });
              Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void showDeleteDialog(String id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Course"),
        content: Text("Are you sure you want to delete '$name'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _firestore.collection('courses').doc(id).delete();
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
