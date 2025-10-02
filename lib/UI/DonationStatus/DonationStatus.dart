import 'package:flutter/material.dart';

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

/// Donation model
class Donation {
  final String foodName;
  final int quantity;
  final String status; // Pending, Accepted, Completed, Expired
  final DateTime date;
  final String? acceptedByNgo; // NGO name (nullable)

  Donation({
    required this.foodName,
    required this.quantity,
    required this.status,
    required this.date,
    this.acceptedByNgo,
  });
}

class DonorDonationStatusScreen extends StatefulWidget {
  const DonorDonationStatusScreen({super.key});

  @override
  State<DonorDonationStatusScreen> createState() =>
      _DonorDonationStatusScreenState();
}

class _DonorDonationStatusScreenState
    extends State<DonorDonationStatusScreen> {
  // Example dummy data (replace with Firebase/DB data later)
  final List<Donation> donations = [
    Donation(
        foodName: "Biriyani",
        quantity: 20,
        status: "Pending",
        date: DateTime.now().subtract(const Duration(hours: 3))),
    Donation(
        foodName: "Veg Meals",
        quantity: 15,
        status: "Accepted",
        date: DateTime.now().subtract(const Duration(days: 1)),
        acceptedByNgo: "Helping Hands NGO"),
    Donation(
        foodName: "Pizza Boxes",
        quantity: 10,
        status: "Completed",
        date: DateTime.now().subtract(const Duration(days: 3)),
        acceptedByNgo: "Food Relief Trust"),
    Donation(
        foodName: "Sandwich",
        quantity: 8,
        status: "Expired",
        date: DateTime.now().subtract(const Duration(days: 5))),
  ];

  /// 🔹 Color for each status
  Color _statusColor(String status) {
    switch (status) {
      case "Pending":
        return Colors.orange;
      case "Accepted":
        return Colors.blue;
      case "Completed":
        return Colors.green;
      case "Expired":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// 🔹 Icon for each status
  IconData _statusIcon(String status) {
    switch (status) {
      case "Pending":
        return Icons.hourglass_empty;
      case "Accepted":
        return Icons.check_circle_outline;
      case "Completed":
        return Icons.done_all;
      case "Expired":
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        centerTitle: true,
        title: const Text(
          "Excess Food",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: donations.length,
        itemBuilder: (context, index) {
          final donation = donations[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _statusColor(donation.status).withOpacity(0.2),
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
                  Text(
                    "Qty: ${donation.quantity} plates\nDate: ${donation.date.toLocal().toString().split('.')[0]}",
                    style: const TextStyle(fontSize: 13),
                  ),
                  if (donation.acceptedByNgo != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      "Accepted by: ${donation.acceptedByNgo}",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ],
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
      ),
    );
  }
}
