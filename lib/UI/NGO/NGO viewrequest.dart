import 'package:flutter/material.dart';

class DonationRequestScreen extends StatefulWidget {
  const DonationRequestScreen({super.key});

  @override
  State<DonationRequestScreen> createState() => _DonationRequestScreenState();
}

class _DonationRequestScreenState extends State<DonationRequestScreen> {
  // Dummy request list with 4 items
  final List<Map<String, String>> requests = [
    {
      "type": "NGO",
      "name": "Helping Hands",
      "foodName": "Rice & Curry",
      "foodType": "Veg",
      "required": "30 plates",
      "location": "Chennai, TN",
      "phone": "9876543210",
    },
    {
      "type": "Individual",
      "name": "John Doe",
      "foodName": "Biryani",
      "foodType": "Non Veg",
      "required": "15 plates",
      "location": "Coimbatore, TN",
      "phone": "9123456780",
    },
    {
      "type": "NGO",
      "name": "Food For All",
      "foodName": "Chapati & Kurma",
      "foodType": "Veg",
      "required": "50 plates",
      "location": "Madurai, TN",
      "phone": "9012345678",
    },
    {
      "type": "Individual",
      "name": "Priya",
      "foodName": "Fried Rice",
      "foodType": "Veg",
      "required": "20 plates",
      "location": "Trichy, TN",
      "phone": "9098765432",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'View Requests', // ✅ Updated title bar
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
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
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${request['type']} - ${request['name']}",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow("Food Name", request['foodName']!),
          const SizedBox(height: 10),
          _buildInfoRow("Food Type", request['foodType']!),
          const SizedBox(height: 10),
          _buildInfoRow("Food Required", request['required']!),
          const SizedBox(height: 10),
          _buildInfoRow("Pickup Location", request['location']!),
          const SizedBox(height: 10),
          _buildInfoRow("Phone", request['phone']!),
          const SizedBox(height: 20),
          _buildActionButtons(),
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
          Text(
            "$title: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black54, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // Handle Approve Request
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Approve Request'),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // Handle Reject Request
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Reject Request'),
          ),
        ),
      ],
    );
  }
}