import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// =========================================================================
// Request Model (Data structure to display)
// =========================================================================
class RequestItem {
  final String id; // Added to reference the document for updates
  final String name;
  final String plates;
  final String status;
  final String dateTime;
  final String donorName;
  final String contact;
  final String location;

  RequestItem({
    required this.id,
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
      id: doc.id, // Capture the document ID
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

  const RequestStatus({super.key});

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
              // Use the new RequestCard widget for each item
              return RequestCard(item: item);
            },
          );
        },
      ),
    );
  }
}

// =========================================================================
// Request Card (Stateful widget to handle local actions like cancellation)
// =========================================================================

class RequestCard extends StatefulWidget {
  final RequestItem item;
  const RequestCard({super.key, required this.item});

  @override
  State<RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<RequestCard> {

  // Helper function to determine status color
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

  // New function to update the request status back to Pending
  void _revertToPending() async {
    try {
      // Reference to the specific document in 'requestsFromNgo'
      DocumentReference docRef = FirebaseFirestore.instance
          .collection('requestsFromNgo')
          .doc(widget.item.id);

      // Update the status
      await docRef.update({
        'status': 'Pending',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Request status reverted to Pending."),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to cancel request: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine the contact display based on status
    final bool isApproved = widget.item.status.toLowerCase() == 'approved';

    final String contactDisplay = isApproved
        ? widget.item.contact
        : "Displayed after admin approval...";

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
            // Food Name and Plates
            Text('${widget.item.name} - ${widget.item.plates}',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),

            // Status Badge
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor(widget.item.status),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                widget.item.status.isEmpty ? 'Not Updated' : widget.item.status,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),

            // Date & Time
            if (widget.item.dateTime.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 4),
                  Text('Date & Time: ${widget.item.dateTime}'),
                ],
              ),
            const SizedBox(height: 6),

            // Donor Name
            Row(
              children: [
                const Icon(Icons.person, size: 16),
                const SizedBox(width: 4),
                Text('Donor: ${widget.item.donorName}'),
              ],
            ),
            const SizedBox(height: 4),

            // Donor Contact (CONDITIONAL DISPLAY)
            Row(
              children: [
                const Icon(Icons.phone, size: 16),
                const SizedBox(width: 4),
                Text(contactDisplay), // Use the conditional display string
              ],
            ),
            const SizedBox(height: 4),

            // Location
            Row(
              children: [
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: 4),
                Text('Location: ${widget.item.location}'),
              ],
            ),

            // --- CANCELLATION BUTTON (CONDITIONAL) ---
            if (isApproved) ...[
              const Divider(height: 20, thickness: 1),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _revertToPending,
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  label: const Text(
                    "Cancel Request",
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}