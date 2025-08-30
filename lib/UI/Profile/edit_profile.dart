import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:project/Reusable/color.dart'; // Assuming this defines appPrimaryColor, etc.
import 'package:project/Reusable/text_styles.dart'; // Assuming this defines MyTextStyle

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> initialData;
  const EditProfileScreen({super.key, required this.initialData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController roleController = TextEditingController();

  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Populate controllers with initial data
    nameController.text = widget.initialData["name"] ?? "";
    phoneController.text = widget.initialData["phone"] ?? "";
    emailController.text = widget.initialData["email"] ?? "";
    addressController.text = widget.initialData["address"] ?? "";
    roleController.text = widget.initialData["type"] ?? "";
  }

  Future<void> _pickImage() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) {
      return widget.initialData["profileImage"]; // Return current URL if no new image
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('user_profile_images')
        .child('${user.uid}.jpg');

    final uploadTask = storageRef.putFile(_selectedImage!);
    final snapshot = await uploadTask.whenComplete(() {});
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No user logged in.")));
        setState(() {
          _isLoading = false;
        });
        return;
      }

      try {
        String? newImageUrl = await _uploadImage();

        await FirebaseFirestore.instance
            .collection("donor")
            .doc(user.uid)
            .update({
          "name": nameController.text.trim(),
          "phone": phoneController.text.trim(),
          "address": addressController.text.trim(),
          "profileImage": newImageUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile updated successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update profile: $e"),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Consistent background color
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green, // Consistent app bar color
        elevation: 0,
        toolbarHeight: 80,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.white, // Consistent icon color
        ),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green), // Consistent loading indicator color
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 20),

              // Profile Image with Pencil Icon
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : (widget.initialData["profileImage"] != null
                          ? NetworkImage(widget.initialData["profileImage"])
                          : const AssetImage('assets/image/profile.png')) as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green, // Consistent with app's color scheme
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(
                            Icons.edit,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              // Use standard theme for text fields for a cleaner look
              Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    cursorColor: Colors.green,
                    decoration: const InputDecoration(
                      labelText: "Full Name",
                      labelStyle: TextStyle(color: Colors.green),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                    ),
                    validator: (value) => value!.isEmpty ? "Enter name" : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneController,
                    cursorColor: Colors.green,
                    decoration: const InputDecoration(
                      labelText: "Phone Number",
                      labelStyle: TextStyle(color: Colors.green),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) => value!.isEmpty ? "Enter phone" : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailController,
                    readOnly: true,
                    cursorColor: Colors.green,
                    decoration: const InputDecoration(
                      labelText: "Email Address",
                      labelStyle: TextStyle(color: Colors.grey),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: addressController,
                    cursorColor: Colors.green,
                    decoration: const InputDecoration(
                      labelText: "Address",
                      labelStyle: TextStyle(color: Colors.green),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                    ),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: roleController,
                    readOnly: true,
                    cursorColor: Colors.grey,
                    decoration: const InputDecoration(
                      labelText: "Role",
                      labelStyle: TextStyle(color: Colors.grey),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Solid Green Save Changes Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _isLoading ? null : _saveChanges,
                  child: _isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    "Save Changes",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}