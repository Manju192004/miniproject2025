import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// =========================================================================
// MOCK/PLACEHOLDER CLASSES FOR DEPENDENCIES
// =========================================================================
class RequestItem {
  final String name;
  final String plates;
  final String status;
  final String dateTime;
  final String donorName;
  final String contact;
  final String location;
  RequestItem({required this.name, required this.plates, required this.status, required this.dateTime, required this.donorName, required this.contact, required this.location});
}

class RequestStatus extends StatelessWidget {
  const RequestStatus({super.key});
  @override
  Widget build(BuildContext context) {
    // This is the placeholder screen the admin navigates to after approval.
    return Scaffold(appBar: AppBar(title: const Text("Request Status")), body: const Center(child: Text("Navigated to Request Status (NGO's perspective).")));
  }
}

class AdminRequestStore {
  AdminRequestStore._privateConstructor();
  static final AdminRequestStore instance = AdminRequestStore._privateConstructor();

  final List<Map<String, dynamic>> requests = [];

  void addRequest(Map<String, dynamic> request) {
    requests.add(request);
  }
}
// =========================================================================


class AdminViewRequestsScreen extends StatefulWidget {
  final Map<String, String>? newRequest; // optional parameter

  const AdminViewRequestsScreen({super.key, this.newRequest});

  @override
  State<AdminViewRequestsScreen> createState() =>
      _AdminViewRequestsScreenState();
}


class _AdminViewRequestsScreenState extends State<AdminViewRequestsScreen> {
  // Reference to the requests collection
  final CollectionReference _ngoRequests =
  FirebaseFirestore.instance.collection('requestsFromNgo');

  // Reference to the original donations collection
  final CollectionReference _addDonationCollection =
  FirebaseFirestore.instance.collection('adddonation');

  // Helper to map Firestore Timestamp to the string format used in the original structure
  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final dateTime = timestamp.toDate();
      // Format: Day-Month-Year Hour:Minute AM/PM
      final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
      final ampm = dateTime.hour >= 12 ? 'PM' : 'AM';
      return "${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year} ${hour}:${dateTime.minute.toString().padLeft(2, '0')} $ampm";
    }
    return 'N/A';
  }

  // CORE LOGIC: Safely maps the Firestore document data.
  Map<String, String> _mapDocumentToRequest(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final quantityRequested = data['quantityRequested'] ?? 0;

    return {
      "id": doc.id, // Request Document ID
      "type": "NGO",
      // ADDED: The ID of the original donation document
      "originalDonationId": data['originalDonationId'] ?? '',
      "name": data['ngoName'] ?? 'Unknown NGO',
      "foodName": data['foodName'] ?? 'N/A',
      "foodType": data['foodType'] ?? 'N/A',
      "required": "$quantityRequested plates",
      "location": data['pickupAddress'] ?? 'N/A',
      "phone": data['donorPhone'] ?? 'N/A',
      "dateTime": _formatTimestamp(data['requestTime']),
      "status": (data['status'] is String) ? data['status'].toLowerCase() : 'pending',
    };
  }

  // CORE LOGIC: The function that updates Firestore. Now handles two updates.
  Future<void> _updateRequestStatus(
      String requestDocId,
      String newStatus,
      String originalDonationId,
      String ngoName, // 💡 FIX: Passed NGO Name is used here
      ) async {
    try {
      String statusLower = newStatus.toLowerCase();

      // 1. Update the status in the 'requestsFromNgo' collection
      await _ngoRequests.doc(requestDocId).update({
        'status': statusLower,
      });

      // 2. CONDITIONAL SECOND UPDATE: Update the original 'adddonation' document
      if (statusLower == 'approved' && originalDonationId.isNotEmpty) {

        // FIX: Use the passed ngoName directly for a reliable and faster update.
        await _addDonationCollection.doc(originalDonationId).update({
          'status': 'Approved',
          // Use the passed NGO's name for display on the donor side
          'acceptedByNgoName': ngoName,
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request status updated to ${newStatus.toUpperCase()}!')),
        );
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: ${e.message}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /*@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('NGO Requests'),
      ),*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        centerTitle: true,  // centers the Column
        toolbarHeight: 90,  // extra height to fit two lines
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
            SizedBox(height: 4),  // spacing between title and subtitle
            Text(
              "NGO Requests",
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
        stream: _ngoRequests.snapshots(), // Stream ALL requests
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error fetching data: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No NGO requests found."));
          }

          final requests = snapshot.data!.docs
              .map(_mapDocumentToRequest)
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return _buildRequestCard(request);
            },
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(Map<String, String> request) {
    Color borderColor = Colors.green;
    if (request['status'] == 'approved') borderColor = Colors.blue;
    if (request['status'] == 'rejected') borderColor = Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade300, blurRadius: 8, offset: const Offset(2, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("${request['type']} - ${request['name']}",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: borderColor)),
          const SizedBox(height: 16),
          _buildInfoRow("Food Name", request['foodName']!),
          _buildInfoRow("Food Type", request['foodType']!),
          _buildInfoRow("Food Required", request['required']!),
          _buildInfoRow("Pickup Location", request['location']!),
          _buildInfoRow("Phone", request['phone']!),
          _buildInfoRow("Date & Time", request['dateTime']!),
          const SizedBox(height: 16),
          _buildStatusRow(request['status']!),
          const SizedBox(height: 12),

          // Action buttons now take the full request map
          if (request.containsKey('id'))
            _buildActionButtons(request),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(" ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.black54, fontSize: 15))),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String status) {
    Color color = Colors.grey;
    if (status == 'approved') color = Colors.blue;
    if (status == 'rejected') color = Colors.red;

    return Row(
      children: [
        const Text("Status: ", style: TextStyle(fontWeight: FontWeight.bold)),
        Text(status.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  // The function that builds the Approve/Reject buttons
  Widget _buildActionButtons(Map<String, String> request) {
    final String requestDocId = request['id']!;
    final String originalDonationId = request['originalDonationId']!; // Retrieve the original donation ID
    final String ngoName = request['name']!; // Retrieve the NGO Name

    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // 1. Call the function to update status to 'approved' in BOTH collections
              _updateRequestStatus(requestDocId, 'approved', originalDonationId, ngoName);

              // 2. Navigation (You can uncomment this if you want to navigate after approval)
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (_) => const RequestStatus(),
              //   ),
              // );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Approve'),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // Call the function to update status to 'rejected' in the requestsFromNgo collection only
              _updateRequestStatus(requestDocId, 'rejected', originalDonationId, ngoName);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Reject'),
          ),
        ),
      ],
    );
  }
}