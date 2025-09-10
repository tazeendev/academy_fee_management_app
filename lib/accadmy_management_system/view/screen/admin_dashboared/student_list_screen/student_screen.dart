import 'package:flutter/material.dart';
import 'package:folding_cell/folding_cell/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({Key? key}) : super(key: key);

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final CollectionReference studentsRef =
  FirebaseFirestore.instance.collection('students');
  final List<GlobalKey<SimpleFoldingCellState>> cellKeys = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Students',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade800,
        elevation: 2,
      ),
      backgroundColor: Colors.grey.shade100,
      body: StreamBuilder<QuerySnapshot>(
        stream: studentsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No students found.'));
          }

          final students = snapshot.data!.docs;

          // Reset cellKeys if length mismatch
          if (cellKeys.length != students.length) {
            cellKeys.clear();
            for (int i = 0; i < students.length; i++) {
              cellKeys.add(GlobalKey<SimpleFoldingCellState>());
            }
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final doc = students[index];
              final data = doc.data() as Map<String, dynamic>;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: StudentFoldingCard(
                  id: doc.id,
                  data: data,
                  cellKey: cellKeys[index],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.shade800,
        onPressed: _showAddStudentDialog,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  void _showAddStudentDialog() {
    final nameController = TextEditingController();
    final courseController = TextEditingController();
    final contactController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Center(
              child: Text('Add Student',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.blue.shade800))),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: courseController,
                  decoration: const InputDecoration(labelText: 'Course ID'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: contactController,
                  decoration: const InputDecoration(labelText: 'Contact'),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                      color: Colors.red.shade400,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                )),
            GestureDetector(
              onTap: () async {
                if (nameController.text.isEmpty ||
                    courseController.text.isEmpty ||
                    contactController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields')));
                  return;
                }

                setStateDialog(() => isLoading = true);

                try {
                  await studentsRef.add({
                    'name': nameController.text,
                    'courseId': courseController.text,
                    'contact': contactController.text,
                  });
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error adding student: $e")));
                } finally {
                  setStateDialog(() => isLoading = false);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 50,
                width: 160,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.blue.shade700, Colors.lightBlueAccent]),
                    borderRadius: BorderRadius.circular(15)),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                  "Add",
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

class StudentFoldingCard extends StatelessWidget {
  final String id;
  final Map<String, dynamic> data;
  final GlobalKey<SimpleFoldingCellState> cellKey;
  final CollectionReference studentsRef =
  FirebaseFirestore.instance.collection('students');

  StudentFoldingCard(
      {Key? key, required this.id, required this.data, required this.cellKey})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleFoldingCell.create(
      key: cellKey,
      frontWidget: _buildFrontCard(context),
      innerWidget: _buildInnerCard(context),
      cellSize: Size(MediaQuery.of(context).size.width, 140),
      padding: const EdgeInsets.all(0),
      animationDuration: const Duration(milliseconds: 400),
      borderRadius: 15,
    );
  }

  Widget _buildFrontCard(BuildContext context) {
    return GestureDetector(
      onTap: () => cellKey.currentState?.toggleFold(),
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
                  color: Colors.black26, blurRadius: 6, offset: Offset(0, 4))
            ]),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white,
              child: Text(
                (data['name'] ?? 'S')[0].toUpperCase(),
                style: TextStyle(
                    color: Colors.blue.shade800, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                data['name'] ?? '',
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInnerCard(BuildContext context) {
    return GestureDetector(
      onTap: () => cellKey.currentState?.toggleFold(),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                  color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
            ]),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Student Details',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(),
            Text('Name: ${data['name'] ?? ''}', style: GoogleFonts.poppins()),
            Text('Course ID: ${data['courseId'] ?? ''}',
                style: GoogleFonts.poppins()),
            Text('Contact: ${data['contact'] ?? ''}',
                style: GoogleFonts.poppins()),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Update'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent),
                  onPressed: () => _showUpdateDialog(context),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Delete'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () async {
                    await studentsRef.doc(id).delete();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateDialog(BuildContext context) {
    final nameController = TextEditingController(text: data['name']);
    final courseController = TextEditingController(text: data['courseId']);
    final contactController = TextEditingController(text: data['contact']);
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Center(
            child: Text(
              'Update Student',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.blue.shade800),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: courseController,
                  decoration: const InputDecoration(labelText: 'Course ID'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: contactController,
                  decoration: const InputDecoration(labelText: 'Contact'),
                ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                decoration: BoxDecoration(
                    gradient:
                    LinearGradient(colors: [Colors.grey.shade300, Colors.grey.shade500]),
                    borderRadius: BorderRadius.circular(15)),
                child: const Text('Cancel',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black87)),
              ),
            ),
            GestureDetector(
              onTap: () async {
                if (nameController.text.isEmpty ||
                    courseController.text.isEmpty ||
                    contactController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields')));
                  return;
                }

                setStateDialog(() => isLoading = true);

                try {
                  await studentsRef.doc(id).update({
                    'name': nameController.text,
                    'courseId': courseController.text,
                    'contact': contactController.text,
                  });
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error updating student: $e")));
                } finally {
                  setStateDialog(() => isLoading = false);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                decoration: BoxDecoration(
                    gradient:
                    LinearGradient(colors: [Colors.blue, Colors.lightBlueAccent]),
                    borderRadius: BorderRadius.circular(15)),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Update',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
