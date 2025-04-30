import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SellerFeedbackScreen extends StatefulWidget {
  const SellerFeedbackScreen({Key? key}) : super(key: key);

  @override
  _SellerFeedbackScreenState createState() => _SellerFeedbackScreenState();
}

class _SellerFeedbackScreenState extends State<SellerFeedbackScreen> {
  final TextEditingController messageController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Listen for changes in the sellerFeedback collection
    firestore.collection('sellerFeedback').orderBy('timestamp', descending: false).snapshots().listen((event) {
      scrollToBottom();
    });
  }

  void scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // Function to send feedback
  void sendFeedback() async {
    final user = auth.currentUser;
    if (user == null) {
      // Show error if user is not logged in
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to send feedback.')),
      );
      return;
    }

    final messageText = messageController.text.trim();
    if (messageText.isEmpty) return; // Don't send empty messages

    try {
      // Add the feedback to the sellerFeedback collection in Firestore
      await firestore.collection('sellerFeedback').add({
        'senderId': user.uid,
        'senderEmail': user.email,
        'message': messageText,
        'timestamp': FieldValue.serverTimestamp(), // Use server timestamp
      });
      messageController.clear(); // Clear the input field
      scrollToBottom();
    } catch (e) {
      // Handle errors, e.g., show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending feedback: $e')),
      );
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Feedback to Admin'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: firestore.collection('sellerFeedback').orderBy('timestamp', descending: false).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No feedback yet. Send the first feedback!'));
                  }
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final messageData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                      final senderEmail = messageData['senderEmail'] ?? 'Unknown';
                      final messageText = messageData['message'] ?? '';
                      final timestamp = messageData['timestamp'] as Timestamp?;
                      final formattedTime = timestamp != null
                          ? DateFormat('HH:mm').format(timestamp.toDate())
                          : 'Unknown Time';
                      final isCurrentUser = auth.currentUser?.uid == messageData['senderId'];
                      final replyText = messageData['reply'] ?? ''; // Get admin reply

                      return buildMessageItem(messageText, senderEmail, formattedTime, isCurrentUser, replyText: replyText);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      labelText: 'Your Feedback',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => sendFeedback(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: sendFeedback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Function to build a message item
  Widget buildMessageItem(String message, String sender, String time, bool isCurrentUser, {String replyText = ''}) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 5),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: isCurrentUser ? Colors.orange[100] : Colors.grey[200],
      borderRadius: BorderRadius.circular(8),
    ),
    alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
    child: Column(
      crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          sender,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isCurrentUser ? Colors.orange[800] : Colors.grey[800],
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
        // Display admin reply
        if (replyText.isNotEmpty && !isCurrentUser) ...[
          const SizedBox(height: 10),
          const Text(
            'Admin Reply:',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          Text(
            replyText,
            style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
          ),
        ],
      ],
    ),
  );
}
}

