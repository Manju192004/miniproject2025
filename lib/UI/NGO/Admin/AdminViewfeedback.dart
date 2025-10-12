import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  // Helper to format the timestamp (now checking for 'Timestamp' type)
  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final dateTime = timestamp.toDate();
      return "${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
    }
    // Handle String format from Firestore (like in your image)
    if (timestamp is String) {
      // Use a cleaner regex to extract just the date/time portion if needed
      return timestamp;
    }
    return 'N/A';
  }

  // Helper to safely extract a string value from a DocumentSnapshot
  String _safeGetString(DocumentSnapshot doc, String field, {String fallback = 'N/A'}) {
    final data = doc.data() as Map<String, dynamic>?;
    return data != null && data.containsKey(field) ? data[field]?.toString() ?? fallback : fallback;
  }

  /*@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Feedback"),
        backgroundColor: Colors.green, // 🟢 Changed to Green
        elevation: 0,
        foregroundColor: Colors.white,
      ),*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              "Feedback",
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.normal,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
  body: StreamBuilder<QuerySnapshot>(
        // 1. Stream from the 'feedback' collection
        stream: FirebaseFirestore.instance.collection('feedback').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.green)); // 🟢 Changed to Green
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error fetching feedback: ${snapshot.error}"));
          }

          final feedbackDocs = snapshot.data?.docs ?? [];

          if (feedbackDocs.isEmpty) {
            return const Center(
              child: Text("No feedback received yet.", style: TextStyle(fontSize: 16, color: Colors.black54)),
            );
          }

          // 2. Display the feedback in a ListView
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: feedbackDocs.length,
            itemBuilder: (context, index) {
              final feedback = feedbackDocs[index];
              final data = feedback.data() as Map<String, dynamic>?;

              // Using correct field names from your Firestore: 'name', 'userType', 'comments', 'overallExperience', 'timestamp'
              final userName = _safeGetString(feedback, 'name', fallback: 'Anonymous User');
              final userType = _safeGetString(feedback, 'userType', fallback: 'User');
              final feedbackText = _safeGetString(feedback, 'comments');
              final rating = _safeGetString(feedback, 'overallExperience');
              final rawTimestamp = data?['timestamp'];
              final dateSubmitted = _formatTimestamp(rawTimestamp);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: User Name and Type
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "$userName ($userType)", // Combining name and userType
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green, // 🟢 Changed to Green
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Display Rating
                          _buildRatingChip(rating),
                        ],
                      ),
                      const Divider(height: 16, thickness: 1),

                      // Feedback Content
                      Text(
                        feedbackText,
                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                      ),

                      const SizedBox(height: 12),

                      // Footer: Date
                      Text(
                        'Submitted on $dateSubmitted',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
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

  // Widget to display the rating visually
  Widget _buildRatingChip(String rating) {
    // Attempt to parse rating as an integer
    int? numericRating = int.tryParse(rating);

    // Display stars if it's a 1-5 rating, otherwise just the value
    if (numericRating != null && numericRating >= 1 && numericRating <= 5) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (index) {
          return Icon(
            index < numericRating ? Icons.star : Icons.star_border,
            size: 18,
            color: Colors.amber, // Keep stars amber for universal rating color
          );
        }),
      );
    }

    // Default chip if rating is not a number or out of range
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1), // 🟢 Changed to Green
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green), // 🟢 Changed to Green
      ),
      child: Text(
        "Rating: $rating",
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green), // 🟢 Changed to Green
      ),
    );
  }
}