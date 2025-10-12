import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/UI/Profile/edit_profile.dart'; // Correct path to your EditProfileScreen
// 💡 Add your LoginScreen import here. Adjust the path as needed.
import 'package:project/UI/login/login.dart' show LoginScreen;

class NgoProfileScreen extends StatelessWidget {
  const NgoProfileScreen({super.key});

  // 💡 Logout confirmation dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to exit?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Close dialog
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              // Close dialog
              if (ctx.mounted) {
                Navigator.of(ctx).pop();
                // Navigate to LoginScreen and remove all previous routes
                // Make sure LoginScreen is correctly imported and available
                Navigator.pushAndRemoveUntil(
                  ctx,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                );
              }
            },
            child: const Text(
              "Yes",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable widget for info card
  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    VoidCallback? onEdit,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.green),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                if (onEdit != null)
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, color: Colors.green),
                  ),
              ],
            ),
            const Divider(color: Colors.grey),
            ...children,
          ],
        ),
      ),
    );
  }

  // Single row of info
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 💡 Styled Logout Button Widget
  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 24, left: 16, right: 16),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        child: ListTile(
          leading: const Icon(Icons.exit_to_app, color: Colors.red),
          title: const Text(
            "Logout",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.red),
          onTap: () => _showLogoutDialog(context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double avatarRadius = screenHeight * 0.07;

    // Get current user UID
    final user = FirebaseAuth.instance.currentUser;

   /* return Scaffold(

      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Excess Food Sharing",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        elevation: 0,
        toolbarHeight: 80,
        centerTitle: true,
        // No actions needed here, as the logout button is in the body
      ),*/return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        toolbarHeight: 90, // increase height to fit two lines
        centerTitle: true,
        title: Column(
          children: const [
            Text(
              "Excess Food Sharing",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 4), // spacing between title and subtitle
            Text(
              "NGO Profile",
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.normal,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),


    body: user == null
          ? const Center(child: Text("No user logged in"))
          : FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection("ngoreg")
            .doc(user.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("User data not found"));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Top Profile Section
                Container(
                  color: Colors.green,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 40, horizontal: 20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: avatarRadius,
                        backgroundColor: Colors.white,
                        child: Text(
                          (data["name"] != null &&
                              data["name"].toString().isNotEmpty)
                              ? data["name"]
                              .toString()
                              .substring(0, 1)
                              .toUpperCase()
                              : "?",
                          style: TextStyle(
                            fontSize: avatarRadius * 0.8,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        data["name"] ?? "No Name",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Profile Information Card
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildInfoCard(
                        title: "Profile Information",
                        icon: Icons.person_outline,
                        onEdit: () {
                          // Navigate to Edit Profile screen and pass data
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfileScreen(
                                initialData: data,
                              ),
                            ),
                          );
                        },
                        children: [
                          _buildInfoRow(
                              "NGO Name", data["name"] ?? ""),
                          _buildInfoRow(
                              "Email", data["email"] ?? ""),
                          _buildInfoRow(
                              "Phone Number", data["phone"] ?? ""),
                          _buildInfoRow(
                              "Address", data["address"] ?? ""),
                          _buildInfoRow(
                              "Role", data["type"] ?? ""), // donor/ngo/admin
                        ],
                      ),
                    ],
                  ),
                ),

                // 💡 Styled Logout Button
                _buildLogoutButton(context),
              ],
            ),
          );
        },
      ),
    );
  }
}