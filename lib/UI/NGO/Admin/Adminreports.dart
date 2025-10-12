import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:project/UI/Login/login.dart';

// Make sure this path is correct

/// Reports Dashboard Screen
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  /*@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.green,
        centerTitle: true,   // centers the column
        toolbarHeight: 90,   // extra height to fit two lines
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
            SizedBox(height: 4), // spacing between main title and subtitle
            Text(
              "Donation Reports",
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.normal,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),*/@override
  /*Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Admin Reports Dashboard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        elevation: 0,
        toolbarHeight: 80,
        centerTitle: true,*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.green,
          centerTitle: true,   // centers the column
          toolbarHeight: 90,   // extra height to fit two lines
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
              SizedBox(height: 4), // spacing between main title and subtitle
              Text(
                "Donation Reports",
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Key Metrics
            const Text(
              "Overview of Our Platform",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 10),
            _buildMetricsGrid(context),
            const Divider(height: 40),

            // Donations Chart
            const Text(
              "Donations Per Day (Last 7 Days)",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 10),
            _buildDonationsChartCard(context),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 1. Metrics Grid
  // =========================================================================
  Widget _buildMetricsGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: [
        _buildMetricCard("Donors", "donor", Icons.person_add, Colors.blue),
        _buildMetricCard("NGOs", "ngoreg", Icons.group_work, Colors.orange),
        _buildMetricCard("Total Donations", "adddonation", Icons.fastfood, Colors.green),
        _buildMetricCard("Completed Pickups", "adddonation", Icons.check_circle, Colors.teal,
            isCompletedCount: true),
        _buildMetricCard("Pending Requests", "adddonation", Icons.pending_actions, Colors.amber,
            isCompletedCount: true),
        _buildMetricCard("Feedbacks", "feedback", Icons.feedback, Colors.purple),
      ],
    );
  }

  // =========================================================================
  // 2. Metric Card
  // =========================================================================
  Widget _buildMetricCard(
      String title, String collection, IconData icon, Color color,
      {bool isCompletedCount = false}) {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection(collection);

    if (isCompletedCount) {
      query = query.where('status', isEqualTo: 'Completed');
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.hasData ? snapshot.data!.docs.length : 0;

        return Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: color.withOpacity(0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.15),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 30, color: color),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =========================================================================
  // 3. Donations Bar Chart
  // =========================================================================
  Widget _buildDonationsChartCard(BuildContext context) {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('adddonation')
          .where('timestamp', isGreaterThanOrEqualTo: sevenDaysAgo)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: SizedBox(height: 250, child: CircularProgressIndicator()));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
              child: SizedBox(height: 250, child: Center(child: Text("No donations in the last 7 days."))));
        }

        final data = snapshot.data!.docs;
        Map<int, int> donationsByDay = _processDonationData(data);

        final maxY = donationsByDay.values.isEmpty
            ? 5.0
            : (donationsByDay.values.reduce((a, b) => a > b ? a : b) + 1).toDouble();

        return Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: BarChart(
            BarChartData(
              maxY: maxY,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) => _getBottomTitles(value),
                    reservedSize: 32,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) => Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    interval: 1,
                    reservedSize: 28,
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              barGroups: _getBarGroups(donationsByDay),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      rod.toY.toInt().toString(),
                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // =========================================================================
  // Helpers
  // =========================================================================
  Map<int, int> _processDonationData(List<QueryDocumentSnapshot> docs) {
    Map<int, int> donationsByDay = {};
    final now = DateTime.now();

    for (int i = 0; i < 7; i++) {
      donationsByDay[i] = 0;
    }

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final timestamp = data['timestamp'];

      if (timestamp is Timestamp) {
        final date = timestamp.toDate();
        final daysDifference = now.difference(date).inDays;

        if (daysDifference >= 0 && daysDifference < 7) {
          donationsByDay[daysDifference] = (donationsByDay[daysDifference] ?? 0) + 1;
        }
      }
    }
    return donationsByDay;
  }

  List<BarChartGroupData> _getBarGroups(Map<int, int> donationsByDay) {
    List<BarChartGroupData> barGroups = [];
    for (int i = 6; i >= 0; i--) {
      barGroups.add(
        BarChartGroupData(
          x: 6 - i,
          barRods: [
            BarChartRodData(
              toY: donationsByDay[i]?.toDouble() ?? 0.0,
              color: i == 0 ? Colors.green.shade700 : Colors.green.shade400,
              width: 16,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
        ),
      );
    }
    return barGroups.reversed.toList();
  }

  Widget _getBottomTitles(double value) {
    const style = TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 10);
    String text;
    final today = DateTime.now();
    final date = today.subtract(Duration(days: (6 - value).toInt()));

    if (value.toInt() == 6) {
      text = 'Today';
    } else {
      text = '${date.day}/${date.month}';
    }

    return SideTitleWidget(
      axisSide: AxisSide.bottom,
      child: Text(text, style: style),
    );
  }

  // =========================================================================
  // Logout Dialog
  // =========================================================================
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to exit?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(), // Close dialog
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Close dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }
}