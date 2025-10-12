import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// =========================================================================
// 0. Placeholder for AdminRequestStore (Simulates local request tracking)
// =========================================================================
class AdminRequestStore {
  AdminRequestStore._();
  static final AdminRequestStore instance = AdminRequestStore._();
  void addRequest(Map<String, dynamic> data) {
    // In a real app, this would update a local state or provider.
    // print("Request added to Admin Store: $data");
  }
}

// =========================================================================
// 1. Donation Model (Data structure and Firestore parsing)
// =========================================================================
class Donation {
  final String id;
  final String foodName;
  final int quantity;
  final String foodType;
  final String bestBefore;
  final String pickupAddress;
  final String deliveryMethod;
  final String donorPhone;

  Donation({
    required this.id,
    required this.foodName,
    required this.quantity,
    required this.foodType,
    required this.bestBefore,
    required this.pickupAddress,
    required this.deliveryMethod,
    required this.donorPhone,
  });

  static String _safeTimestampToString(dynamic data) {
    if (data is Timestamp) {
      final dateTime = data.toDate();
      // Format: MM/DD/YYYY HH:MM
      return "${dateTime.month}/${dateTime.day}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
    } else if (data is String) {
      return data;
    }
    return 'N/A';
  }

  // --- FIX APPLIED HERE: Extract numeric part from quantity string ---
  static int _extractQuantity(dynamic value) {
    if (value is int) {
      return value;
    } else if (value is String) {
      // Regex to find the first sequence of one or more digits
      final RegExp digitRegex = RegExp(r'\d+');
      final match = digitRegex.firstMatch(value);
      if (match != null) {
        // Extract the matched number (e.g., "10" from "10plates") and parse it
        return int.tryParse(match.group(0)!) ?? 0;
      }
    }
    return 0;
  }
  // -----------------------------------------------------------------

  factory Donation.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    return Donation(
      id: doc.id,
      foodName: data['foodName'] ?? 'N/A',
      // Use the corrected method to safely parse the quantity
      quantity: _extractQuantity(data['quantity']),
      foodType: data['foodType'] ?? 'N/A',
      // The Firestore image shows 'bestBefore' is a Timestamp in the left pane,
      // but the data structure shows it as a String. We use the safe method.
      bestBefore: _safeTimestampToString(data['bestBefore']),
      pickupAddress: data['pickupAddress'] ?? 'N/A',
      deliveryMethod: data['deliveryMethod'] ?? 'N/A',
      // Check for 'phoneNumber' (as seen in the image) or 'donorPhone'
      donorPhone: data['phoneNumber'] ?? data['donorPhone'] ?? 'N/A',
    );
  }
}

// =========================================================================
// 2. NGO View Requests List Screen (The main list container)
// =========================================================================

class NGOViewRequestScreen extends StatelessWidget {
  NGOViewRequestScreen({super.key});

  // Reference the 'adddonation' collection
  final CollectionReference _donations =
  FirebaseFirestore.instance.collection('adddonation');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        centerTitle: true,
        toolbarHeight: 90,// centers the whole column
        title: Column(
          children: const [
            Text(
              "Excess Food Share",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                fontSize: 24,
              ),
            ),
            SizedBox(height: 20), // small spacing between title and subtitle
            Text(
              "DonationRequest",
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),


      // Uses StreamBuilder to get ALL documents in real-time
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        // Explicitly cast the stream type
        stream: _donations.snapshots() as Stream<QuerySnapshot<Map<String, dynamic>>>,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error fetching data: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No available donations found."));
          }

          final donationsList = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: donationsList.length,
            itemBuilder: (context, index) {
              final document = donationsList[index];
              final donation = Donation.fromFirestore(document);

              // Renders each document using the detailed card style
              return DonationDetailCard(
                donation: donation,
              );
            },
          );
        },
      ),
    );
  }
}

// =========================================================================
// 3. Donation Detail Card (Stateful widget for the styled, interactive card)
// =========================================================================

class DonationDetailCard extends StatefulWidget {
  final Donation donation;

  const DonationDetailCard({
    super.key,
    required this.donation,
  });

  @override
  State<DonationDetailCard> createState() => _DonationDetailCardState();
}

class _DonationDetailCardState extends State<DonationDetailCard> {
  final TextEditingController quantityController = TextEditingController();

  // --- Placeholder NGO Details (MOCK DATA - Replace with actual Auth/User data) ---
  final String currentNgoId = "ngo_user_123";
  final String ngoName = "Helping Hand Foundation";
  // ---------------------------------------------------------------------------------

  // Reference to the new collection for NGO requests
  final CollectionReference _ngoRequests =
  FirebaseFirestore.instance.collection('requestsFromNgo');

  @override
  void dispose() {
    quantityController.dispose();
    super.dispose();
  }

  // =================================================
  // FUNCTION TO HANDLE 'SEND REQUEST' (Write to requestsFromNgo)
  // =================================================
  void _sendRequest() async {
    // Check if the donation quantity is zero or less
    if (widget.donation.quantity <= 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Donation Unavailable"),
          content: const Text(
              "This donation is currently unavailable (Quantity is 0)."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    final entered = int.tryParse(quantityController.text.trim()) ?? 0;

    if (entered <= 0 || entered > widget.donation.quantity) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Invalid Quantity"),
          content: Text(
              "Donor has only ${widget.donation.quantity} plates.\nPlease enter a number between 1 and ${widget.donation.quantity}."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    Map<String, dynamic> requestData = {
      // NGO Details
      "ngoId": currentNgoId,
      "ngoName": ngoName,

      // Donation Details
      "originalDonationId": widget.donation.id,
      "donorPhone": widget.donation.donorPhone,
      "foodName": widget.donation.foodName,
      "foodType": widget.donation.foodType,
      "pickupAddress": widget.donation.pickupAddress,
      "deliveryMethod": widget.donation.deliveryMethod,

      // Request Details
      "quantityRequested": entered,
      "quantityAvailable": widget.donation.quantity,
      "requestTime": FieldValue.serverTimestamp(),
      "status": "Pending",
    };

    try {
      // Add the request to the 'requestsFromNgo' collection
      await _ngoRequests.add(requestData);
      AdminRequestStore.instance.addRequest(requestData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Request sent for $entered plates of ${widget.donation.foodName}. Awaiting admin approval."),
            backgroundColor: Colors.green,
          ),
        );
      }
      quantityController.clear();

    } on FirebaseException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to send request: ${e.message}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  // =================================================
  // FUNCTION TO HANDLE 'REJECT REQUEST' - PLACEHOLDER ACTION
  // =================================================
  void _rejectRequest() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reject Donation"),
        content: const Text("Are you sure you want to mark this donation as rejected?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog

              // --- PLACEHOLDER ACTION: NO DATABASE OPERATION ---
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Donation rejected (no database changes made)."),
                    backgroundColor: Colors.grey,
                  ),
                );
              }
              // --- END PLACEHOLDER ACTION ---
            },
            child: const Text("Reject (Local)"),
          ),
        ],
      ),
    );
  }

  // Exact styling function from your preferred detailed view
  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(value, style: const TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow("Food Name", widget.donation.foodName),
            const SizedBox(height: 12),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              // Displays the dynamically parsed and corrected quantity
              decoration: InputDecoration(
                labelText: "Quantity (Max: ${widget.donation.quantity})",
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow("Food Type", widget.donation.foodType),
            const SizedBox(height: 12),
            _buildInfoRow("Best Before", widget.donation.bestBefore),
            const SizedBox(height: 12),
            _buildInfoRow("Pickup Address", widget.donation.pickupAddress),
            const SizedBox(height: 12),
            _buildInfoRow("Delivery Method", widget.donation.deliveryMethod),
            const SizedBox(height: 12),
            _buildInfoRow("Donor Phone", widget.donation.donorPhone),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: widget.donation.quantity > 0 ? _sendRequest : null, // Disable if quantity is 0
                    child: const Text(
                      "Send Request",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _rejectRequest,
                    child: const Text(
                      "Reject Request",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}