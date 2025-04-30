import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import for FirebaseAuth


class FeedbackToAdminScreen extends StatefulWidget {
  const FeedbackToAdminScreen({Key? key}) : super(key: key);

  @override
  _FeedbackToAdminScreenState createState() => _FeedbackToAdminScreenState();
}

class _FeedbackToAdminScreenState extends State<FeedbackToAdminScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();
  String _userRole = ''; // To store the user's role


  @override
  void initState() {
    super.initState();
    _loadUserRole(); // Load user role when the screen initializes
    // Listen for changes in the 'feedback' collection
    _firestore.collection('feedback').orderBy('timestamp', descending: false).snapshots().listen((event) {
      _scrollToBottom();
    });
  }

  // Function to load the user's role from Firestore
  Future<void> _loadUserRole() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _userRole = userData['role'] ??
                ''; // Default to empty string if role is null
          });
        }
      } catch (e) {
        print("Error loading user role: $e");
        // Handle error, e.g., show a snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load user role: $e')),
        );
      }
    }
  }

  // Function to send feedback
  void _sendFeedback() async {
    final user = _auth.currentUser;
    if (user == null) {
      // Show error if user is not logged in
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to send feedback.')),
      );
      return;
    }

    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return; // Don't send empty messages

     // Determine the collection based on user role.  Default to 'feedback'
    String collectionName = 'feedback';
    if (_userRole == 'buyer') {
      collectionName = 'buyerFeedback';
    } else if (_userRole == 'seller') {
      collectionName = 'sellerFeedback';
    }

    try {
      // Add the feedback to the  collection in Firestore
      await _firestore.collection(collectionName).add({
        'senderId': user.uid,
        'senderEmail': user.email,
        'message': messageText,
        'timestamp': FieldValue.serverTimestamp(), // Use server timestamp
      });
      _messageController.clear(); // Clear the input field
      _scrollToBottom();
    } catch (e) {
      // Handle errors, e.g., show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending feedback: $e')),
      );
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback to Admin'), // Changed title
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                // Changed collection to  dynamic
                stream: _firestore.collection('feedback').orderBy('timestamp', descending: false).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No feedback yet. Send the first feedback!')); //changed message
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
                      final isCurrentUser = _auth.currentUser?.uid == messageData['senderId'];
                      final replyText = messageData['reply'] ?? '';

                      return _buildMessageItem(messageText, senderEmail, formattedTime, isCurrentUser, replyText: replyText);
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
                    controller: _messageController,
                    decoration: const InputDecoration(
                      labelText: 'Your Feedback', // Changed label
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendFeedback(), // Changed function name
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _sendFeedback, // Changed function name
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
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
  Widget _buildMessageItem(String message, String sender, String time, bool isCurrentUser, {String replyText = ''}) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 5),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: isCurrentUser ? Colors.blue[100] : Colors.grey[200],
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
            color: isCurrentUser ? Colors.blue[800] : Colors.grey[800],
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
        //show admin reply
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

