import 'package:firebase_app/accadmy_management_system/view/widget/form-feilds/text_form_feilds.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
            return Center(child: CircularProgressIndicator(color: Colors.white));
          }
          final coursesId = snapshot.data!.docs;
          if (coursesId.isEmpty) {
            return Center(child: Text("No Courses Found"));
          }
          while (cellKeys.length < coursesId.length) {
            cellKeys.add(GlobalKey<SimpleFoldingCellState>());
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: coursesId.length,
            itemBuilder: (context, index) {
              final doc = coursesId[index];
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
              "PKR ${data['fee']?.toDouble().toStringAsFixed(2) ?? '0.00'}",
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
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, fontSize: 18),
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
                onPressed: () => _showOptions(context, id, data),
                icon: const Icon(Icons.edit, size: 18),
                label: const Text("Options"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showAddDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final feeController = TextEditingController();
    bool isLoading = false;

    showGeneralDialog(
      context: context,
      barrierLabel: "Add Course",
      barrierDismissible: true,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        final curvedAnim = Curves.easeInOut.transform(anim1.value);
        return Transform.translate(
          offset: Offset(0, (1 - curvedAnim) * 200),
          child: Opacity(
            opacity: anim1.value,
            child: StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                title: Center(
                  child: Text("Add New Course",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.blue.shade800)),
                ),
                content: SingleChildScrollView(
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
                          descController.text.isEmpty ||
                          feeController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Please fill all fields')));
                        return;
                      }

                      setState(() => isLoading = true);
                      final id = DateTime.now().millisecondsSinceEpoch.toString();

                      try {
                        await _firestore.collection('courses').doc(id).set({
                          'name': nameController.text,
                          'description': descController.text,
                          'fee': double.tryParse(feeController.text) ?? 0,
                        });

                        setState(() => isLoading = false);
                        Navigator.pop(context);
                      } catch (error) {
                        setState(() => isLoading = false);
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text('Error: $error')));
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 700),
                      height: 50,
                      width: 260,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: isLoading
                                  ? [Colors.blue.shade700, Colors.lightBlueAccent]
                                  : [Colors.lightBlueAccent, Colors.blueAccent]),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.blueAccent.withOpacity(0.5),
                                blurRadius: 12,
                                spreadRadius: 1,
                                offset: const Offset(0, 5))
                          ],
                          borderRadius: BorderRadius.circular(15)),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text('Save Course',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------- UPDATE & DELETE ----------------
  void _showOptions(BuildContext context, String id, Map<String, dynamic> data) {
    showGeneralDialog(
      context: context,
      barrierLabel: "Options",
      barrierDismissible: true,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        final curvedAnim = Curves.easeInOut.transform(anim1.value);
        return Transform.scale(
          scale: curvedAnim,
          child: Opacity(
            opacity: anim1.value,
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Center(
                child: Text(
                  "Choose Action",
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.blue.shade800),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Update Button
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      showUpdateDialog(context, id, data);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          gradient:
                          const LinearGradient(colors: [Colors.orangeAccent, Colors.deepOrange]),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.deepOrange.withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 5))
                          ]),
                      child: Text(
                        "Update",
                        style: GoogleFonts.poppins(
                            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  // Delete Button
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      showDeleteDialog(context, id, data['name']);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Colors.redAccent, Colors.red]),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.red.withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 5))
                          ]),
                      child: Text(
                        "Delete",
                        style: GoogleFonts.poppins(
                            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void showUpdateDialog(BuildContext context, String id, Map<String, dynamic> data) {
    final nameController = TextEditingController(text: data['name']);
    final descController = TextEditingController(text: data['description']);
    final feeController = TextEditingController(text: data['fee']?.toString() ?? '0');
    bool isLoading = false;

    showGeneralDialog(
      context: context,
      barrierLabel: "Update",
      barrierDismissible: true,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        final curvedAnim = Curves.easeInOut.transform(anim1.value);
        return Transform.scale(
          scale: curvedAnim,
          child: Opacity(
            opacity: anim1.value,
            child: StatefulBuilder(
              builder: (context, setStateDialog) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: Center(
                  child: Text(
                    "Update Course",
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.blue.shade800),
                  ),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      CustomTextField(controller: nameController, hintText: "Course Name"),
                      const SizedBox(height: 10),
                      CustomTextField(controller: descController, hintText: "Description"),
                      const SizedBox(height: 10),
                      CustomTextField(
                          controller: feeController,
                          hintText: "Fee",
                          keyboardType: TextInputType.number),
                    ],
                  ),
                ),
                actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                actions: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          gradient:
                          LinearGradient(colors: [Colors.grey.shade300, Colors.grey.shade500]),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.4),
                                blurRadius: 7,
                                offset: const Offset(0, 5))
                          ]),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.poppins(
                            color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () async {
                      setStateDialog(() => isLoading = true);
                      try {
                        await FirebaseFirestore.instance.collection('courses').doc(id).update({
                          'name': nameController.text,
                          'description': descController.text,
                          'fee': double.tryParse(feeController.text) ?? data['fee'],
                        });
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error updating course: $e")));
                      } finally {
                        setStateDialog(() => isLoading = false);
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Colors.blue, Colors.lightBlueAccent]),
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
                        "Update",
                        style: GoogleFonts.poppins(
                            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void showDeleteDialog(BuildContext context, String id, String name) {
    showGeneralDialog(
      context: context,
      barrierLabel: "Delete",
      barrierDismissible: true,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        final curvedAnim = Curves.easeInOut.transform(anim1.value);
        return Transform.scale(
          scale: curvedAnim,
          child: Opacity(
            opacity: anim1.value,
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Center(
                child: Text(
                  "Delete Course",
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 20, color: Colors.red.shade800),
                ),
              ),
              content: Text(
                "Are you sure you want to delete '$name'?",
                style: GoogleFonts.poppins(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              actions: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        gradient:
                        LinearGradient(colors: [Colors.grey.shade300, Colors.grey.shade500]),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.4),
                              blurRadius: 7,
                              offset: const Offset(0, 5))
                        ]),
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.poppins(
                          color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () async {
                    try {
                      await FirebaseFirestore.instance.collection('courses').doc(id).delete();
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text("Error deleting course: $e")));
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Colors.redAccent, Colors.red]),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.red.withOpacity(0.4),
                              blurRadius: 7,
                              offset: const Offset(0, 5))
                        ]),
                    child: Text(
                      "Delete",
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
