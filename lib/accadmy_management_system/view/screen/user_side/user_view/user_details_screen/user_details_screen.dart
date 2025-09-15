import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app/accadmy_management_system/view/screen/admin_dashboared/courses_screen/add_course/add_course.dart';
import 'package:firebase_app/accadmy_management_system/view/widget/form-feilds/text_form_feilds.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class CreateStudentDetailsForm extends StatefulWidget {
  const CreateStudentDetailsForm({super.key});

  @override
  State<CreateStudentDetailsForm> createState() => _CreateStudentDetailsFormState();
}

class _CreateStudentDetailsFormState extends State<CreateStudentDetailsForm> {
  TextEditingController nameController=TextEditingController();
  TextEditingController fatherController=TextEditingController();
  TextEditingController aboutController=TextEditingController();
  TextEditingController emailController=TextEditingController();
  TextEditingController phoneController=TextEditingController();
  TextEditingController addressController=TextEditingController();
  TextEditingController cityController=TextEditingController();
  bool isLoading=false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            CustomTextField(controller: nameController, hintText: 'Enter the Institute Name',labelText:
            'Name',labelColor: Color(0xff0D5EA6),hintColor: Colors.grey,prefixIcon: Icons.person,),
            SizedBox(
              height: 20,
            ),
            CustomTextField(controller: fatherController, hintText: 'Enter the Father Name',labelText:
            ' Father Name',labelColor: Color(0xff0D5EA6),hintColor: Colors.grey,prefixIcon: Icons.person,),
            SizedBox(
              height: 20,
            ),
            CustomTextField(controller:addressController, hintText: 'Enter the Institute description',labelText:
            'Description',labelColor: Color(0xff0D5EA6),hintColor: Colors.grey,prefixIcon: Icons.description,),
            SizedBox(
              height: 20,
            ),
            CustomTextField(controller: emailController, hintText: 'Enter the Email',labelText:
            'Email',labelColor: Color(0xff0D5EA6),hintColor: Colors.grey,prefixIcon: Icons.email,keyboardType: TextInputType.emailAddress,),
            SizedBox(
              height: 20,
            ),
            CustomTextField(controller: phoneController, hintText: 'Enter the phone number',labelText:
            'Phone',labelColor: Color(0xff0D5EA6),hintColor: Colors.grey,prefixIcon: Icons.phone,keyboardType: TextInputType.phone,),
            SizedBox(
              height: 20,
            ),
            CustomTextField(controller: addressController, hintText: 'Enter the Address',labelText:
            'Address',labelColor: Color(0xff0D5EA6),hintColor: Colors.grey,prefixIcon: Icons.edit_location_sharp,keyboardType: TextInputType.streetAddress,),
            SizedBox(
              height: 20,
            ),
            CustomTextField(controller: cityController, hintText: 'Enter the city ',labelText:
            'City',labelColor: Color(0xff0D5EA6),hintColor: Colors.grey,prefixIcon: Icons.location_city,),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () async {
                try {
                  setState(() {
                    isLoading = true;
                  });
                  if (nameController.text.isEmpty || aboutController.text.isEmpty||emailController.text.isEmpty||
                      phoneController.text.isEmpty||addressController.text.isEmpty||cityController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Please enter amount and due date")));
                    return;
                  }
                  final id=FirebaseAuth.instance.currentUser!.uid;
                  await FirebaseFirestore.instance
                      .collection('institute')
                      .doc(id)
                      .set({
                    'name':nameController.text,
                    'des':aboutController.text,
                    'email':emailController.text,
                    'phone':phoneController.text,
                    'address':addressController.text,
                    'city':cityController.text,
                    'createdby':id,
                  });
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateCourseScreen()));
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
                  "Save Data",
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
