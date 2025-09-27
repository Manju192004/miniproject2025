import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NgoHomeScreen extends StatefulWidget {
  const NgoHomeScreen({super.key});

  @override
  State<NgoHomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<NgoHomeScreen> {
  String? userName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final uid = user.uid;

        // Check in donor collection
        DocumentSnapshot donorDoc = await FirebaseFirestore.instance
            .collection('donor')
            .doc(uid)
            .get();

        if (donorDoc.exists) {
          setState(() {
            userName = donorDoc['name'];
            isLoading = false;
          });
          return;
        }

        // Check in ngo collection
        DocumentSnapshot ngoDoc = await FirebaseFirestore.instance
            .collection('ngo')
            .doc(uid)
            .get();

        if (ngoDoc.exists) {
          setState(() {
            userName = ngoDoc['name'];
            isLoading = false;
          });
          return;
        }

        // Check in admin collection
        DocumentSnapshot adminDoc = await FirebaseFirestore.instance
            .collection('admin')
            .doc(uid)
            .get();

        if (adminDoc.exists) {
          setState(() {
            userName = adminDoc['name'];
            isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint("Error fetching user name: $e");
    }

    setState(() {
      userName = "User"; // fallback
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(
        title: const Text(
          "Excess Food Sharing",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Welcome Section
          Container(
            color: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLoading
                      ? "Loading..."
                      : "Welcome back, $userName",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Your kindness feeds hope.",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // List Section
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildListItem(
                    context,
                    label: "View Donations",
                    icon: Icons.remove_red_eye_sharp,
                    iconColor: Colors.black,
                    circleColor: Colors.yellow,
                  ),
                  _buildListItem(
                    context,
                    label: "Request Status",
                    icon: Icons.list_alt,
                    iconColor: Colors.black,
                    circleColor: Colors.orange,
                  ),
                  _buildListItem(
                    context,
                    label: "Post Feedback",
                    icon: Icons.chat,
                    iconColor: Colors.black,
                    circleColor: Colors.yellow,
                  ),
                  _buildListItem(
                    context,
                    label: "Profile",
                    icon: Icons.person,
                    iconColor: Colors.white,
                    circleColor: Colors.blue,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(
      BuildContext context, {
        required String label,
        required IconData icon,
        required Color iconColor,
        required Color circleColor,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 20),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
