import 'package:cloud_firestore/cloud_firestore.dart';

class ExpiredDonationCleanup {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> cleanupExpiredDonations() async {
    try {
      final now = DateTime.now();
      final snapshot = await _firestore
          .collection('adddonation')
          .where('bestBefore', isLessThan: now)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      if (snapshot.docs.isNotEmpty) {
        await batch.commit();
        print('🧹 Deleted ${snapshot.docs.length} expired donations');
      }
    } catch (e) {
      print('❌ Error cleaning up expired donations: $e');
    }
  }
}