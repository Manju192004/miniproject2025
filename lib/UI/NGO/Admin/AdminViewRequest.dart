import 'package:flutter/material.dart';
import 'package:project/UI/NGO/ngorequest_status.dart';

// Shared in-memory request store
class AdminRequestStore {
  AdminRequestStore._privateConstructor();
  static final AdminRequestStore instance = AdminRequestStore._privateConstructor();

  final List<Map<String, String>> requests = [];

  void addRequest(Map<String, String> request) {
    requests.add(request);
  }
}


class AdminViewRequestsScreen extends StatefulWidget {
  final Map<String, String>? newRequest; // optional parameter

  const AdminViewRequestsScreen({super.key, this.newRequest});

  @override
  State<AdminViewRequestsScreen> createState() =>
      _AdminViewRequestsScreenState();
}


class _AdminViewRequestsScreenState extends State<AdminViewRequestsScreen> {
  final List<Map<String, String>> requests = [
    {
      "type": "NGO",
      "name": "Helping Hands",
      "foodName": "Rice & Curry",
      "foodType": "Veg",
      "required": "30 plates",
      "location": "Chennai, TN",
      "phone": "9876543210",
      "dateTime": "01-09-2025 10:30 AM",
      "status": "pending",
    },
    {
      "type": "Individual",
      "name": "John Doe",
      "foodName": "Biryani",
      "foodType": "Non Veg",
      "required": "15 plates",
      "location": "Coimbatore, TN",
      "phone": "9123456780",
      "dateTime": "01-09-2025 02:15 PM",
      "status": "pending",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Excess Food Sharing'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return _buildRequestCard(request);
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
          if (request['status'] == 'pending') _buildActionButtons(request),
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

  Widget _buildActionButtons(Map<String, String> request) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // Create multiple RequestItem if needed
              List<RequestItem> requestItems = [
                RequestItem(
                  name: request['foodName']!,
                  plates: request['required']!,
                  status: 'Approved',
                  dateTime: request['dateTime']!,
                  donorName: request['name']!,
                  contact: request['phone']!,
                  location: request['location']!,
                ),
                // You can add more items here if multiple requests from same donor
              ];

              // Navigate to RequestStatus with multiple items
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RequestStatus(items: requestItems),
                ),
              );

              setState(() {
                request['status'] = 'approved';
              });
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
              setState(() {
                request['status'] = 'rejected';
              });
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