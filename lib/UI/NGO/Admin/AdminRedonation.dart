import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RedonationScreen extends StatelessWidget {
  const RedonationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Redonation Requests"),
        backgroundColor: Colors.red,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('donations')
            .where('status', isEqualTo: 'rejected') // Only rejected donations
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final donations = snapshot.data!.docs;

          if (donations.isEmpty) {
            return const Center(
              child: Text(
                "No rejected donations found.",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          }

          return ListView.builder(
            itemCount: donations.length,
            itemBuilder: (context, index) {
              var donation = donations[index];

              return Card(
                margin: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: ListTile(
                  title: Text(
                    donation['foodName'] ?? "No Name",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("🍲 Quantity: ${donation['quantity']}"),
                      Text("📍 Location: ${donation['location']}"),
                      Text("🕒 Best Before: ${donation['bestBefore']}"),
                      Text("👤 Donor: ${donation['donorName']}"),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: ElevatedButton(
                    onPressed: () {
                      _reassignDonation(context, donation.id);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green),
                    child: const Text("Reassign"),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _reassignDonation(BuildContext context, String donationId) async {
    try {
      // Update status back to "pending" for redonation
      await FirebaseFirestore.instance
          .collection('donations')
          .doc(donationId)
          .update({'status': 'pending'});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Donation moved for reallocation."),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
