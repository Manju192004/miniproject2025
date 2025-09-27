import 'package:flutter/material.dart';


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
}

class RequestStatus extends StatelessWidget {
  const RequestStatus({super.key});

  Color _statusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.amber;
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _displayStatus(String status) {
    return status.isEmpty ? 'Not Updated' : status;
  }

  @override
  Widget build(BuildContext context) {
    final List<RequestItem> items = [
      RequestItem(
        name: 'Dosa',
        plates: '10 plates',
        status: 'Pending',
        dateTime: '13 Aug 2025 8:27 AM',
        donorName: 'T Vgnhesh Aarif',
        contact: '9876547689',
        location: 'Chennai, TN',
      ),
      RequestItem(
        name: 'Idly',
        plates: '15 plates',
        status: 'Approved',
        dateTime: '18 Aug 2025 8:21 AM',
        donorName: 'Dön P Donnate',
        contact: '9876547690',
        location: 'Coimbatore, TN',
      ),
      RequestItem(
        name: 'Biriyani',
        plates: '6 plates',
        status: 'Rejected',
        dateTime: '18 Nov 2025 12:00 PM',
        donorName: 'Riyan Subhashini',
        contact: '9876547691',
        location: 'Madurai, TN',
      ),
      RequestItem(
        name: 'Biriyani',
        plates: '6 plates',
        status: '',
        dateTime: '',
        donorName: 'Riyan Subhashni',
        contact: '9876547691',
        location: 'Salem, TN',
      ),
    ];

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
      body: ListView.builder(
        itemCount: items.length,
        padding: const EdgeInsets.all(12),
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
                  Text(
                    '${item.name} - ${item.plates}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor(_displayStatus(item.status)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _displayStatus(item.status),
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (item.dateTime.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 4),
                        Text('Date & Time: ${item.dateTime}'),
                      ],
                    ),
                  ],
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
