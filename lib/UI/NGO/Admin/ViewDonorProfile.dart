import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DonorProfileScreen extends StatelessWidget {
  const DonorProfileScreen({super.key});

  // Helper function for safe data access and filtering unwanted fields
  Map<String, dynamic> _safeGetData(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>?;
      if (data != null) {
        // Exclude unwanted fields
        data.remove('uid');
        data.remove('profileImage');
        data.remove('createdAt'); // <--- EXCLUDING THIS FIELD
        return data;
      }
    } catch (e) {
      debugPrint("Error casting donor document data: $e");
    }
    return {};
  }

  // Helper to format keys like 'donorType' to 'Donor Type'
  String _formatKey(String key) {
    String displayKey = key
        .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(0)!}')
        .trim();
    return displayKey[0].toUpperCase() + displayKey.substring(1);
  }

  // Helper to choose the right icon for common fields
  IconData _getIconForKey(String key) {
    switch (key.toLowerCase()) {
      case 'address':
        return Icons.location_on;
      case 'phone':
        return Icons.phone;
      case 'email':
        return Icons.email;
      case 'donortype':
        return Icons.business;
      case 'type':
        return Icons.badge;
      default:
        return Icons.info_outline;
    }
  }

  /*@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Donor Profiles"),
        backgroundColor: Colors.green,
        elevation: 0,
        foregroundColor: Colors.white,
      ),*/@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        centerTitle: true,   // centers the column
        toolbarHeight: 90,   // extra height for two lines
        title: Column(
          children: const [
            Text(
              "Excess Food Share",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 4), // spacing between main title and subtitle
            Text(
              "Donor Profile",
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),


  body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('donor').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.green));
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final donors = snapshot.data?.docs ?? [];

          if (donors.isEmpty) {
            return const Center(
                child: Text("No Donors Found.", style: TextStyle(fontSize: 16)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: donors.length,
            itemBuilder: (context, index) {
              var donor = donors[index];
              final donorData = _safeGetData(donor);

              // Nested FutureBuilder to get the count of related donations
              return FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('adddonation')
                    .where('donorId', isEqualTo: donor.id)
                    .get(),
                builder: (context, donationSnapshot) {
                  int donationCount = 0;
                  if (donationSnapshot.connectionState == ConnectionState.done && donationSnapshot.hasData) {
                    donationCount = donationSnapshot.data!.docs.length;
                  }

                  final name = donorData['name']?.toString() ?? 'No Name';

                  // Dynamically build the list of all fields with icons and better spacing
                  List<Widget> detailWidgets = donorData.entries.map((entry) {
                    if (entry.key == 'name') return const SizedBox.shrink();

                    return _buildDetailRow(
                      icon: _getIconForKey(entry.key),
                      title: _formatKey(entry.key),
                      value: entry.value?.toString() ?? 'N/A',
                    );
                  }).toList();

                  // Add the donation count field
                  detailWidgets.add(
                    _buildDetailRow(
                      icon: Icons.food_bank,
                      title: "Donations",
                      value: donationCount.toString(),
                      isHighlight: true,
                    ),
                  );

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Header (Name)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        // Card Body (Details)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: detailWidgets,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // Styled Widget for each detail row
  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
    bool isHighlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: isHighlight ? Colors.orange : Colors.grey[700]),
          const SizedBox(width: 12),
          Text(
            "$title: ",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: isHighlight ? Colors.orange : Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15,
                color: isHighlight ? Colors.black : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}