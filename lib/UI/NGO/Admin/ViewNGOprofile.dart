import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NGOProfileScreen extends StatelessWidget {
  const NGOProfileScreen({super.key});

  // Helper function for safe data access and filtering unwanted fields
  Map<String, dynamic> _safeGetData(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>?;
      if (data != null) {
        // Exclude unwanted/redundant fields
        data.remove('uid');
        data.remove('govtProofUrl');
        data.remove('createdAt'); // Exclude timestamp
        return data;
      }
    } catch (e) {
      debugPrint("Error casting NGO document data: $e");
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
      case 'name':
        return Icons.account_balance;
      case 'type':
        return Icons.badge;
      default:
        return Icons.info_outline;
    }
  }

  // Styled Widget for each detail row
  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
    bool isHighlight = false,
  }) {
    // 🟢 Color changed from Colors.blue to Colors.green
    Color highlightColor = Colors.green;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: isHighlight ? highlightColor : Colors.grey[700]),
          const SizedBox(width: 12),
          Text(
            "$title: ",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: isHighlight ? highlightColor : Colors.black87,
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        centerTitle: true,   // centers the Column
        toolbarHeight: 90,   // extra height to fit both lines
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
              "NGO Profile",
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),

 /* @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("NGO Profiles"),
        backgroundColor: Colors.green, // 🟢 Color changed to Green
        elevation: 0,
        foregroundColor: Colors.white,
      ),*/
      // StreamBuilder fetches ALL documents from the 'ngoreg' collection
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('ngoreg').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 🟢 Color changed to Green
            return const Center(child: CircularProgressIndicator(color: Colors.green));
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final ngos = snapshot.data?.docs ?? [];

          if (ngos.isEmpty) {
            return const Center(
                child: Text("No NGO Profiles Found.", style: TextStyle(fontSize: 16)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: ngos.length,
            itemBuilder: (context, index) {
              final ngo = ngos[index];
              final ngoData = _safeGetData(ngo);
              final ngoName = ngoData['name']?.toString() ?? 'No Name';

              // FutureBuilder to count requests/donations related to this NGO
              return FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('requestsFromNgo')
                    .where('ngoId', isEqualTo: ngo.id)
                    .get(),
                builder: (context, requestSnapshot) {
                  int totalRequests = 0;
                  int approvedRequests = 0;

                  if (requestSnapshot.connectionState == ConnectionState.done && requestSnapshot.hasData) {
                    totalRequests = requestSnapshot.data!.docs.length;
                    approvedRequests = requestSnapshot.data!.docs
                        .where((doc) => doc['status'] == 'approved')
                        .length;
                  }

                  // Dynamically build the list of all fields
                  List<Widget> detailWidgets = ngoData.entries.map((entry) {
                    if (entry.key == 'name') return const SizedBox.shrink(); // Skip name

                    return _buildDetailRow(
                      icon: _getIconForKey(entry.key),
                      title: _formatKey(entry.key),
                      value: entry.value?.toString() ?? 'N/A',
                    );
                  }).toList();

                  // Add the request/donation counts to the list of fields
                  detailWidgets.add(
                    _buildDetailRow(
                      icon: Icons.list_alt,
                      title: "Total Requests",
                      value: totalRequests.toString(),
                      isHighlight: true,
                    ),
                  );
                  detailWidgets.add(
                    _buildDetailRow(
                      icon: Icons.check_circle_outline,
                      title: "Approved Requests",
                      value: approvedRequests.toString(),
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
                            color: Colors.green, // 🟢 Color changed to Green
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          child: Text(
                            ngoName,
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
}