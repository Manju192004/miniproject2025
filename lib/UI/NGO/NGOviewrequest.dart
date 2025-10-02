import 'package:flutter/material.dart';
import 'package:project/UI/NGO/Admin/AdminViewRequest.dart';

class NGOViewRequestScreen extends StatefulWidget {
  const NGOViewRequestScreen({super.key});

  @override
  State<NGOViewRequestScreen> createState() => _NGOViewRequestScreenState();
}

class _NGOViewRequestScreenState extends State<NGOViewRequestScreen> {
  final String foodName = "Rice Biryani";
  final int donorQuantity = 10;
  final String foodType = "Non-Veg";
  final String bestBefore = "Today 8:00 PM";
  final String pickupAddress = "123 Main Street";
  final String deliveryMethod = "NGO will collect";
  final String donorPhone = "9876543210";

  final TextEditingController quantityController = TextEditingController();

  void _sendRequest() {
    final entered = int.tryParse(quantityController.text.trim()) ?? 0;

    if (entered <= 0 || entered > donorQuantity) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Invalid Quantity"),
          content: Text(
              "Donor has only $donorQuantity plates.\nPlease enter a number between 1 and $donorQuantity."),
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

    // Add request to singleton (background)
    AdminRequestStore.instance.addRequest({
      "type": "NGO",
      "name": "NGO Name",
      "foodName": foodName,
      "foodType": foodType,
      "required": "$entered plates",
      "location": pickupAddress,
      "phone": donorPhone,
      "dateTime": DateTime.now().toString(),
      "status": "pending",
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Request sent for $entered plates of $foodName."),
        backgroundColor: Colors.green,
      ),
    );

    // Clear input field
    quantityController.clear();
  }

  void _rejectRequest() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reject Request"),
        content: const Text("Are you sure you want to reject this donation?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Donation request rejected."),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text("Reject"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("View Donation Request"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow("Food Name", foodName),
            const SizedBox(height: 12),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Quantity (Max: $donorQuantity)",
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow("Food Type", foodType),
            const SizedBox(height: 12),
            _buildInfoRow("Best Before", bestBefore),
            const SizedBox(height: 12),
            _buildInfoRow("Pickup Address", pickupAddress),
            const SizedBox(height: 12),
            _buildInfoRow("Delivery Method", deliveryMethod),
            const SizedBox(height: 12),
            _buildInfoRow("Donor Phone", donorPhone),
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
                    onPressed: _sendRequest,
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
}
