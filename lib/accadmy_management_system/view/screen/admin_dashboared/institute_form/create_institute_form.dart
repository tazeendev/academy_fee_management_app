import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app/accadmy_management_system/view/screen/admin_dashboared/courses_screen/add_course/add_course.dart';
import 'package:firebase_app/accadmy_management_system/view/widget/form-feilds/text_form_feilds.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class CreateInstituteForm extends StatefulWidget {
  const CreateInstituteForm({super.key});

  @override
  State<CreateInstituteForm> createState() => _CreateInstituteFormState();
}

class _CreateInstituteFormState extends State<CreateInstituteForm> {
  TextEditingController nameController=TextEditingController();
  TextEditingController desController=TextEditingController();
  TextEditingController emailController=TextEditingController();
  TextEditingController phoneController=TextEditingController();
  TextEditingController addressController=TextEditingController();
  TextEditingController cityController=TextEditingController();
  bool isLoading=false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(controller: nameController, hintText: 'Enter the Institute description',labelText:
        'Description',labelColor: Color(0xff0D5EA6),hintColor: Colors.grey,prefixIcon: Icons.description,),
        SizedBox(
          height: 20,
        ),
        CustomTextField(controller: emailController, hintText: 'Enter the Email',labelText:
        'Email',labelColor: Color(0xff0D5EA6),hintColor: Colors.grey,prefixIcon: Icons.email,),
        SizedBox(
          height: 20,
        ),
        CustomTextField(controller: phoneController, hintText: 'Enter the phone number',labelText:
        'Phone',labelColor: Color(0xff0D5EA6),hintColor: Colors.grey,prefixIcon: Icons.phone,),
        SizedBox(
          height: 20,
        ),
        CustomTextField(controller: addressController, hintText: 'Enter the Address',labelText:
        'Address',labelColor: Color(0xff0D5EA6),hintColor: Colors.grey,prefixIcon: Icons.edit_location_sharp,),
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
              if (nameController.text.isEmpty || desController.text.isEmpty||emailController.text.isEmpty||
                  phoneController.text.isEmpty||addressController.text.isEmpty||cityController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Please enter amount and due date")));
                return;
              }
final id=FirebaseAuth.instance.currentUser!.uid;
              await FirebaseFirestore.instance
                  .collection('institute')
                  .doc()
                  .set({
                'name':nameController.text,
                'des':desController.text,
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
    );
  }
}
