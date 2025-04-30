import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import for FirebaseAuth

class AdminChatScreen extends StatefulWidget {
  const AdminChatScreen({Key? key}) : super(key: key);

  @override
  _AdminChatScreenState createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Feedback'), // Changed title to 'User Feedback'
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                // Changed the stream to 'feedback' collection
                stream: _firestore.collection('feedback').orderBy('timestamp', descending: false).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No feedback from users yet.')); //changed message
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final messageData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                      final senderEmail = messageData['senderEmail'] ?? 'Unknown';
                      final messageText = messageData['message'] ?? '';
                      final timestamp = messageData['timestamp'] as Timestamp?;
                      final formattedTime = timestamp != null
                          ? DateFormat('HH:mm').format(timestamp.toDate())
                          : 'Unknown Time';
                      final replyText = messageData['reply'] ?? ''; // Get the reply
                      final adminReplyTimestamp = messageData['adminReplyTimestamp'] as Timestamp?;
                      final formattedReplyTime = adminReplyTimestamp != null
                          ? DateFormat('HH:mm').format(adminReplyTimestamp.toDate())
                          : 'Unknown Time';
                      final repliedByAdminEmail = messageData['repliedByAdminEmail'] ?? '';

                      final messageId = snapshot.data!.docs[index].id;

                      return _buildMessageItem(
                        messageId: messageId,
                        message: messageText,
                        sender: senderEmail,
                        time: formattedTime,
                        reply: replyText,
                        replyTime: formattedReplyTime,
                        repliedByAdminEmail: repliedByAdminEmail,
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // Function to build a message item
  Widget _buildMessageItem(
      {required String messageId,
      required String message,
      required String sender,
      required String time,
      required String reply,
      required String replyTime,
      required String repliedByAdminEmail,
      }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green, // changed color
            ),
          ),
          const SizedBox(height: 2),
          Text(
            message,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 2),
          Text(
            time,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          // Display the reply if it exists
          if (reply.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text(
              'Admin Reply:',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            Text(
              reply,
              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            Text(
              "Replied by: $repliedByAdminEmail at $replyTime",
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }
}

