import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project/UI/Login/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  bool isDonor = true;
  bool _isFirebaseInitialized = false;
  bool _isLoading = false;

  // Controllers
  final TextEditingController donorTypeController =
  TextEditingController(text: 'Individual');
  final TextEditingController nameOrgController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  FirebaseAuth? auth;

  // NGO proof upload
  FilePickerResult? _pickedFile;
  String? _fileName;
  String? _fileUrl;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      try {
        Firebase.app();
        setState(() {
          _isFirebaseInitialized = true;
          auth = FirebaseAuth.instance;
        });
        return;
      } catch (_) {}
      await Firebase.initializeApp();
      setState(() {
        _isFirebaseInitialized = true;
        auth = FirebaseAuth.instance;
      });
    } catch (e) {
      print("Firebase initialization error: $e");
    }
  }

  @override
  void dispose() {
    donorTypeController.dispose();
    nameOrgController.dispose();
    emailController.dispose();
    addressController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      setState(() {
        _pickedFile = result;
        _fileName = result.files.single.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isFirebaseInitialized) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text("Initializing Firebase..."),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD6F5D6), Color(0xFFA8E6A3)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(15.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'REGISTER',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      _buildSelectionButtons(),
                      const SizedBox(height: 20),
                      Text(
                        isDonor
                            ? 'DONOR REGISTRATION'
                            : 'NGO REGISTRATION',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      isDonor ? _buildDonorForm() : _buildNgoForm(),
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                isDonor = true;
                donorTypeController.text = 'Individual';
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDonor ? Colors.green.shade100 : Colors.white,
              foregroundColor: isDonor ? Colors.green : Colors.black,
              side: BorderSide(
                color: isDonor ? Colors.green : Colors.grey.shade400,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Donor', style: TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                isDonor = false;
                donorTypeController.text = 'Organization';
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: !isDonor ? Colors.green.shade100 : Colors.white,
              foregroundColor: !isDonor ? Colors.green : Colors.black,
              side: BorderSide(
                color: !isDonor ? Colors.green : Colors.grey.shade400,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('NGO', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }

  Widget _buildDonorForm() {
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Type of Donor',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildDropdownField(
            items: const ['Individual', 'Organization'],
            hint: donorTypeController.text,
          ),
          const SizedBox(height: 16),
          _buildTextField('Name / Organization', 'Your Name or Organization',
              controller: nameOrgController),
          const SizedBox(height: 16),
          _buildTextField('Email ID', 'you@example.com',
              controller: emailController),
          const SizedBox(height: 16),
          _buildTextField('Address', 'Your Address',
              controller: addressController),
          const SizedBox(height: 16),
          _buildTextField('Phone No', 'Your Phone Number',
              controller: phoneController),
          const SizedBox(height: 16),
          _buildTextField('Password', 'Enter Password',
              obscureText: true, controller: passwordController),
          const SizedBox(height: 16),
          _buildTextField('Confirm Password', 'Confirm Password',
              obscureText: true, controller: confirmPasswordController),
          const SizedBox(height: 30),
          _buildRegisterButton(),
        ],
      ),
    );
  }

  Widget _buildNgoForm() {
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Type of NGO',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildDropdownField(items: const ['Organization'], hint: 'Organization'),
          const SizedBox(height: 16),
          _buildTextField('Name / Organization', 'NGO Name or Organization',
              controller: nameOrgController),
          const SizedBox(height: 16),
          _buildTextField('Email ID', 'ngo@example.com',
              controller: emailController),
          const SizedBox(height: 16),
          _buildTextField('Address', 'NGO Address',
              controller: addressController),
          const SizedBox(height: 16),
          _buildTextField('Phone No.', 'NGO Phone Number',
              controller: phoneController),
          const SizedBox(height: 16),
          const Text('Upload Government Proof',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickFile,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  Text(
                    'Choose File',
                    style: TextStyle(color: Colors.blue.shade700),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _fileName ?? 'No file chosen',
                      style: const TextStyle(color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      softWrap: false,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField('Password', 'Enter Password',
              obscureText: true, controller: passwordController),
          const SizedBox(height: 16),
          _buildTextField('Confirm Password', 'Confirm Password',
              obscureText: true, controller: confirmPasswordController),
          const SizedBox(height: 30),
          _buildRegisterButton(),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint,
      {bool obscureText = false, TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.green, width: 2.0),
            ),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(
      {required List<String> items, required String hint}) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      value: donorTypeController.text.isNotEmpty
          ? donorTypeController.text
          : items.first,
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            donorTypeController.text = newValue;
          });
        }
      },
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : () async {
          final donorType = donorTypeController.text.trim();
          final name = nameOrgController.text.trim();
          final email = emailController.text.trim();
          final address = addressController.text.trim();
          final phone = phoneController.text.trim();
          final password = passwordController.text;
          final confirmPassword = confirmPasswordController.text;

          if (donorType.isEmpty ||
              name.isEmpty ||
              email.isEmpty ||
              address.isEmpty ||
              phone.isEmpty ||
              password.isEmpty ||
              confirmPassword.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please fill in all fields')),
            );
            return;
          }

          if (password != confirmPassword) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Passwords do not match')),
            );
            return;
          }

          final emailRegex =
          RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
          if (!emailRegex.hasMatch(email)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Please enter a valid email address')),
            );
            return;
          }

          if (!isDonor && _pickedFile == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Please upload government proof')),
            );
            return;
          }

          setState(() {
            _isLoading = true;
          });

          try {
            UserCredential userCredential =
            await auth!.createUserWithEmailAndPassword(
              email: email,
              password: password,
            );

            final uid = userCredential.user!.uid;

            // Upload NGO proof if NGO
            if (!isDonor && _pickedFile != null) {
              final path =
                  "ngo_proofs/$uid/${_pickedFile!.files.single.name}";
              final fileBytes = _pickedFile!.files.single.bytes;

              if (fileBytes != null) {
                final ref =
                FirebaseStorage.instance.ref().child(path);
                await ref.putData(fileBytes);
                _fileUrl = await ref.getDownloadURL();
              }
            }

            // Different data for donor and NGO
            Map<String, dynamic> userData;
            if (isDonor) {
              userData = {
                'uid': uid,
                'type': 'Donor',
                'donorType': donorType,
                'name': name,
                'email': email,
                'address': address,
                'phone': phone,
                'createdAt': FieldValue.serverTimestamp(),
              };
            } else {
              userData = {
                'uid': uid,
                'type': 'NGO',
                'donorType': donorType,
                'name': name,
                'email': email,
                'address': address,
                'phone': phone,
                'govtProofUrl': _fileUrl ?? '',
                'createdAt': FieldValue.serverTimestamp(),
              };
            }

            await FirebaseFirestore.instance
                .collection(isDonor ? 'donor' : 'ngoreg')
                .doc(uid)
                .set(userData);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Registration successful!')),
            );

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const LoginScreen()),
            );
          } on FirebaseAuthException catch (e) {
            String message = 'Registration failed';
            if (e.code == 'email-already-in-use') {
              message = 'This email is already in use.';
            } else if (e.code == 'weak-password') {
              message = 'The password is too weak.';
            } else if (e.message != null) {
              message = e.message!;
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('An error occurred: $e')),
            );
          } finally {
            setState(() {
              _isLoading = false;
            });
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ).copyWith(
          overlayColor: MaterialStateProperty.all(Colors.green.shade700),
        ),
        child: const Text(
          'Register',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}