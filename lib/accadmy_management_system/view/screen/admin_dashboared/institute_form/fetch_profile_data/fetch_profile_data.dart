import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../widget/form-feilds/text_form_feilds.dart';

class FetchProfileData extends StatefulWidget {
  const FetchProfileData({super.key});

  @override
  State<FetchProfileData> createState() => _FetchProfileDataState();
}

class _FetchProfileDataState extends State<FetchProfileData> {
  String name = "";
  String des = "";
  String email = "";
  String phone = "";
  String address = "";
  String city = "";
  bool isLoading = true;
  String? docId;

  Future<void> fetchInstitute() async {
    try {
      final uId = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot snapshot =
      await FirebaseFirestore.instance.collection('institute').doc(uId).get();
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          docId = snapshot.id;
          name = data['name'] ?? "";
          des = data['des'] ?? "";
          email = data['email'] ?? "";
          phone = data['phone'] ?? "";
          address = data['address'] ?? "";
          city = data['city'] ?? "";
          isLoading = false;
        });
      } else {
setState(() {
  isLoading=false;
});        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('No Institute Found')));
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> deleteInstitute() async {
    try {
      if (docId != null) {
        await FirebaseFirestore.instance
            .collection('institute')
            .doc(docId)
            .delete();
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("Institute deleted")),
        );
        setState(() {
          name = "";
          des = "";
          email = "";
          phone = "";
          address = "";
          city = "";
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
  Future<void> updateInstitute(Map<String, dynamic> data) async {
    try {
      if (docId != null) {
        await FirebaseFirestore.instance
            .collection('institute')
            .doc(docId)
            .update(data);
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("Institute updated")),
        );
        fetchInstitute(); // refresh after update
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
  void showOptionsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Manage Institute"),
          content: const Text("Do you want to update or delete this profile?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                showUpdateDialog();
              },
              child: const Text("Update"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await deleteInstitute();
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void showUpdateDialog() {
    TextEditingController nameControlller = TextEditingController(text: name);
    TextEditingController desController=TextEditingController(text: des);
    TextEditingController emailController=TextEditingController(text:email);
    TextEditingController phoneController=TextEditingController(text: phone);
    TextEditingController addressController=TextEditingController(text: address);
    TextEditingController cityController = TextEditingController(text: city);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:  Text("Update Institute"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(controller: nameControlller, hintText: 'Enter the Institute description',labelText:
              'Description',labelColor: Color(0xff0D5EA6),hintColor: Colors.grey,prefixIcon: Icons.description,),
              CustomTextField(controller:desController, hintText: 'Enter the Institute description',labelText:
              'Description',labelColor: Color(0xff0D5EA6),hintColor: Colors.grey,prefixIcon: Icons.description,),
              CustomTextField(controller:emailController, hintText: 'Enter the Institute description',labelText:
              'Description',labelColor: Color(0xff0D5EA6),hintColor: Colors.grey,prefixIcon: Icons.description,),
              CustomTextField(controller: phoneController, hintText: 'Enter the Institute description',labelText:
              'Description',labelColor: Color(0xff0D5EA6),hintColor: Colors.grey,prefixIcon: Icons.description,),
              CustomTextField(controller: addressController, hintText: 'Enter the Institute description',labelText:
              'Description',labelColor: Color(0xff0D5EA6),hintColor: Colors.grey,prefixIcon: Icons.description,),
              CustomTextField(controller: cityController, hintText: 'Enter the Institute description',labelText:
              'Description',labelColor: Color(0xff0D5EA6),hintColor: Colors.grey,prefixIcon: Icons.description,),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await updateInstitute({
                  'name': nameControlller.text,
                  'des': desController.text,
                  'email': emailController.text,
                  'phone': phoneController.text,
                  'address': addressController.text,
                  'city': cityController.text,
                });
                Navigator.pop(context);
              },
              child:Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchInstitute();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Institute Profile'), centerTitle: true),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : name.isEmpty
          ? const Center(child: Text("No data"))
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: Column(
                children: [
                  Text("Name: $name"),
                  Text("Description: $des"),
                  Text("Email: $email"),
                  Text("Phone: $phone"),
                  Text("Address: $address"),
                  Text("City: $city"),
                ],
              ),
              trailing: const Icon(Icons.more_vert),
              onTap: showOptionsDialog,
            ),
          ),
        ],
      ),
    );
  }
}
