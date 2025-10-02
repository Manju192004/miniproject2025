import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// =========================================================================
// Request Model (Data structure to display)
// =========================================================================
class RequestItem {
  final String name;
  final String plates;
  final String status;
  final String dateTime;
  final String donorName;
  final String contact;
  final String location;

  RequestItem({
    required this.name,
    required this.plates,
    required this.status,
    required this.dateTime,
    required this.donorName,
    required this.contact,
    required this.location,
  });

  // Factory method to map a Firestore document from 'requestsFromNgo'
  factory RequestItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Helper to safely format Firestore Timestamp
    String formatTimestamp(dynamic timestamp) {
      if (timestamp is Timestamp) {
        final dateTime = timestamp.toDate();
        // Format: Month/Day/Year Hour:Minute
        return "${dateTime.month}/${dateTime.day}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
      }
      return 'N/A';
    }

    return RequestItem(
      name: data['foodName'] ?? 'N/A',
      plates: "${data['quantityRequested'] ?? 0} plates", // Uses quantityRequested
      status: data['status'] ?? 'N/A',
      dateTime: formatTimestamp(data['requestTime']),
      // The donor's name was not explicitly saved, using a placeholder/default
      donorName: data['donorName'] ?? 'Donor',
      contact: data['donorPhone'] ?? 'No Contact',
      location: data['pickupAddress'] ?? 'N/A',
    );
  }
}

// =========================================================================
// Request Status Screen (Fetches and displays filtered data)
// =========================================================================

class RequestStatus extends StatelessWidget {
  // --- MOCK NGO ID ---
  // 🛑 IMPORTANT: In a real app, replace this placeholder with the actual
  // authenticated user ID (e.g., from FirebaseAuth.instance.currentUser!.uid)
  final String currentNgoId = "ngo_user_123";
  // -------------------

  // The constructor is now a const constructor and does not require an 'items' list
  const RequestStatus({super.key});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.amber;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define the Firestore Query: Filter 'requestsFromNgo' by 'ngoId'
    final Stream<QuerySnapshot> requestStream = FirebaseFirestore.instance
        .collection('requestsFromNgo')
        .where('ngoId', isEqualTo: currentNgoId) // FILTER APPLIED HERE
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'Excess Food\nRequest Status',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        toolbarHeight: 90,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: requestStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error fetching requests: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No requests sent by your NGO yet."));
          }

          // Map the Firestore documents to the RequestItem model
          final List<RequestItem> items = snapshot.data!.docs
              .map((doc) => RequestItem.fromFirestore(doc))
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Existing Styling Preserved ---
                      Text('${item.name} - ${item.plates}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Container(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _statusColor(item.status),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.status.isEmpty ? 'Not Updated' : item.status,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (item.dateTime.isNotEmpty)
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16),
                            const SizedBox(width: 4),
                            Text('Date & Time: ${item.dateTime}'),
                          ],
                        ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.person, size: 16),
                          const SizedBox(width: 4),
                          Text('Donor: ${item.donorName}'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 16),
                          const SizedBox(width: 4),
                          Text(item.contact),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16),
                          const SizedBox(width: 4),
                          Text('Location: ${item.location}'),
                        ],
                      ),
                      // --- End Existing Styling ---
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}