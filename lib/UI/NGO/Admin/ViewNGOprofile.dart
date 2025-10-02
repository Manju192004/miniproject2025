import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NGOProfileScreen extends StatelessWidget {
  const NGOProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("NGO Profiles"),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('ngo').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final ngos = snapshot.data!.docs;

          if (ngos.isEmpty) {
            return const Center(
              child: Text(
                "No NGO profiles found.",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ngos.length,
            itemBuilder: (context, index) {
              final ngo = ngos[index];

              return FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('donations')
                    .where('assignedNgoId', isEqualTo: ngo.id)
                    .get(),
                builder: (context, donationSnapshot) {
                  int totalDonations = 0;
                  int pendingDonations = 0;

                  if (donationSnapshot.hasData) {
                    totalDonations = donationSnapshot.data!.docs.length;
                    pendingDonations = donationSnapshot.data!.docs
                        .where((doc) => doc['status'] == 'pending')
                        .length;
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      title: Text(
                        ngo['name'] ?? "No Name",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          Text("📍 Address: ${ngo['address'] ?? 'N/A'}"),
                          Text("📞 Phone: ${ngo['phone'] ?? 'N/A'}"),
                          Text("🟢 Total Donations: $totalDonations"),
                          Text("🟡 Pending Donations: $pendingDonations"),
                        ],
                      ),
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
