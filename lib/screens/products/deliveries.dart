import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DeliveriesScreen extends StatelessWidget {
  const DeliveriesScreen({Key? key}) : super(key: key);

  Future<void> _markAsDelivered(BuildContext context, String orderId) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'orderStatus': 'Delivered',
        'isReadyForDelivery': false, // No longer ready for delivery
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order marked as Delivered.')),
      );
    } catch (error) {
      print('Error updating order status: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update order status.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAuth.instance.currentUser?.getIdTokenResult().then((idTokenResult) {
      print('DeliveriesScreen Claims: ${idTokenResult.claims}');
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Deliveries'),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('orderStatus', isEqualTo: 'In Transit')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            print('Firestore Error: ${snapshot.error}');
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data != null && snapshot.data!.docs.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final orderDoc = snapshot.data!.docs[index];
                final orderData = orderDoc.data() as Map<String, dynamic>;
                final buyerName = orderData['buyerName'] as String? ?? 'N/A';
                final deliveryAddress = orderData['deliveryAddress'] as String? ?? 'N/A';
                final List<dynamic> orderItems = orderData['orderItems'] as List? ?? [];
                final String orderStatus = orderData['orderStatus'] ?? '';

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order ID: ${orderDoc.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Buyer: $buyerName'),
                        Text('Delivery Address: $deliveryAddress'),
                        const SizedBox(height: 8),
                        Text('Status: $orderStatus'),
                        const SizedBox(height: 8),
                        const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: orderItems.length,
                          itemBuilder: (itemContext, itemIndex) {
                            final item = orderItems[itemIndex] as Map<String, dynamic>;
                            return Text('- ${item['name']} x ${item['quantity']}');
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (orderStatus == 'In Transit')
                              ElevatedButton(
                                onPressed: () => _markAsDelivered(context, orderDoc.id),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Delivered'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No shipments in transit.'));
          }
        },
      ),
    );
  }
}