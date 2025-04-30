import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ViewSellerFeedbackScreen extends StatelessWidget {
  const ViewSellerFeedbackScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Feedback'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('sellerFeedback')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No feedback yet.'));
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final feedback = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                final senderEmail = feedback['senderEmail'] ?? 'Unknown';
                final message = feedback['message'] ?? 'No message';
                final timestamp = feedback['timestamp'] as Timestamp?;
                final formattedTime = timestamp != null
                    ? DateFormat('HH:mm').format(timestamp.toDate())
                    : 'Unknown Time';

                return buildFeedbackItem(senderEmail, message, formattedTime);
              },
            );
          },
        ),
      ),
    );
  }

  // Function to build the feedback item UI
  Widget buildFeedbackItem(String senderEmail, String message, String time) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              senderEmail,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(message),
            const SizedBox(height: 5),
            Text(
              time,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
