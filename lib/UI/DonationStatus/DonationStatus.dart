import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Note: Uncomment this in your real app once you have the dependency
// import 'package:firebase_auth/firebase_auth.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DonorDonationStatusScreen(),
    );
  }
}

// =========================================================================
// 1. Donation Model (Updated to include document ID)
// =========================================================================
class Donation {
  final String id; // 💡 Document ID
  final String foodName;
  final int quantity;
  final String status; // Pending, Accepted, Completed, Expired
  final DateTime date;
  final String? acceptedByNgo; // NGO name (nullable)

  Donation({
    required this.id, // 💡 Required ID
    required this.foodName,
    required this.quantity,
    required this.status,
    required this.date,
    this.acceptedByNgo,
  });

  // Factory method to parse data from the 'adddonation' collection
  factory Donation.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    int _extractQuantity(dynamic value) {
      if (value is int) return value;
      if (value is String) {
        final RegExp digitRegex = RegExp(r'\d+');
        final match = digitRegex.firstMatch(value);
        return int.tryParse(match?.group(0) ?? '') ?? 0;
      }
      return 0;
    }

    DateTime _parseTimestamp(dynamic timestamp) {
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      }
      if (doc.metadata.hasPendingWrites) {
        return DateTime.now();
      }
      return DateTime(2000);
    }

    return Donation(
      id: doc.id,
      foodName: data['foodName'] ?? 'N/A',
      quantity: _extractQuantity(data['quantity']),
      status: data['status'] ?? 'Pending',
      date: _parseTimestamp(data['timestamp']),
      acceptedByNgo: data['acceptedByNgoName'],
    );
  }
}

// =========================================================================
// 2. DonorDonationStatusScreen (With added App Name container)
// =========================================================================
class DonorDonationStatusScreen extends StatefulWidget {
  const DonorDonationStatusScreen({super.key});

  @override
  State<DonorDonationStatusScreen> createState() =>
      _DonorDonationStatusScreenState();
}

class _DonorDonationStatusScreenState
    extends State<DonorDonationStatusScreen> {

  final String _currentDonorId = "donor_uid_12345";
  final CollectionReference<Map<String, dynamic>> _donationsCollection =
  FirebaseFirestore.instance.collection('adddonation');

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case "pending":
        return Colors.orange;
      case "approved":
      case "accepted":
        return Colors.blue;
      case "completed":
        return Colors.green;
      case "rejected":
      case "expired":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case "pending":
        return Icons.hourglass_empty;
      case "approved":
      case "accepted":
        return Icons.check_circle_outline;
      case "completed":
        return Icons.done_all;
      case "rejected":
      case "expired":
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  Future<void> _markAsCompleted(String donationId) async {
    try {
      await _donationsCollection.doc(donationId).update({
        'status': 'Completed',
        'completionTime': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Donation marked as Completed!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to mark as complete: ${e.message}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // 🟢 HEADER CONTAINER ADDED HERE
          Container(
            width: double.infinity,
            color: Colors.green[700],
            padding: const EdgeInsets.only(top: 45, bottom: 16),
            child: Column(
              children: const [
                Text(
                  "Excess Food Share",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "My Donation Status",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // 🔹 StreamBuilder Section (Unchanged)
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _donationsCollection
                  .where('donorId', isEqualTo: _currentDonorId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text("You haven't made any donations yet."));
                }

                final donationsList = snapshot.data!.docs
                    .map((doc) => Donation.fromFirestore(doc))
                    .toList();
                donationsList.sort((a, b) => b.date.compareTo(a.date));

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: donationsList.length,
                  itemBuilder: (context, index) {
                    final donation = donationsList[index];
                    final statusLower = donation.status.toLowerCase();
                    final bool showCompleteButton =
                        statusLower == 'pending' ||
                            statusLower == 'approved' ||
                            statusLower == 'accepted';

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                          _statusColor(donation.status).withOpacity(0.2),
                          child: Icon(
                            _statusIcon(donation.status),
                            color: _statusColor(donation.status),
                          ),
                        ),
                        title: Text(
                          donation.foodName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Qty: ${donation.quantity} plates",
                                style: const TextStyle(fontSize: 13)),
                            Text(
                              "Date: ${donation.date.toLocal().toString().substring(0, 16)}",
                              style: const TextStyle(fontSize: 13),
                            ),
                            if (donation.acceptedByNgo != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                "Accepted by: ${donation.acceptedByNgo}",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _statusColor(donation.status),
                                ),
                              ),
                            ],
                            if (showCompleteButton)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: SizedBox(
                                  height: 30,
                                  child: ElevatedButton.icon(
                                    onPressed: () =>
                                        _markAsCompleted(donation.id),
                                    icon: const Icon(Icons.check, size: 16),
                                    label: const Text(
                                      "Mark as Donated",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.lightGreen,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _statusColor(donation.status).withOpacity(0.1),
                            border: Border.all(color: _statusColor(donation.status)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            donation.status,
                            style: TextStyle(
                              color: _statusColor(donation.status),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
