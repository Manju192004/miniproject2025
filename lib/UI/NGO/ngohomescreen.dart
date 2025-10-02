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

  // Helper function to safely fetch the name from a collection
  Future<String?> _getNameFromCollection(String uid, String collection) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection(collection)
          .doc(uid)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        // Assuming the name field is consistently named 'name'
        return data['name'] as String?;
      }
    } catch (e) {
      debugPrint("Error fetching name from $collection: $e");
    }
    return null;
  }

  Future<void> _fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    String? fetchedName;

    if (user != null) {
      final uid = user.uid;

      // 1. Check in NGOREG collection (Prioritized for this screen based on your DB image)
      fetchedName = await _getNameFromCollection(uid, 'ngoreg');

      // 2. Check other collections only if the name wasn't found in 'ngoreg'
      if (fetchedName == null) {
        fetchedName = await _getNameFromCollection(uid, 'donor');
      }

      if (fetchedName == null) {
        fetchedName = await _getNameFromCollection(uid, 'admin');
      }

    }

    // Update state once, with the best name found or a fallback
    setState(() {
      userName = fetchedName ?? "User";
      isLoading = false;
    });

    if (userName == "User") {
      debugPrint("Warning: User is null or UID not found in 'ngoreg', 'donor', or 'admin' collections, or the 'name' field is missing.");
    }
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
                  // Display the name directly
                  isLoading
                      ? "Loading..."
                      : "Welcome back, ${userName!}",
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
        // onTap: () {
        //   // Handle navigation here (e.g., Navigator.push for the respective screen)
        //   debugPrint('$label tapped');
        // },
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