import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewSalesScreen extends StatelessWidget {
  final String sellerId;

  const ViewSalesScreen({Key? key, required this.sellerId}) : super(key: key);

  Future<void> _markAsShipped(BuildContext context, String orderId) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update(
        {
          'orderStatus': 'Shipped',
          'isReadyForDelivery': true, // Set isReadyForDelivery to true
        },
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order marked as shipped and ready for delivery.'),
        ),
      );
    } catch (error) {
      print('Error updating order status: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update order status.')),
      );
    }
  }

  Future<void> _handOverToDelivery(BuildContext context, String orderId) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update(
        {
          'orderStatus': 'In Transit', // Updated status to "In Transit"
          // You might also add a field for assigned delivery personnel here
          // 'assignedDeliveryAgentId': 'someDeliveryAgentId',
        },
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Order handed over for delivery and is now in transit.',
          ),
        ),
      );
      // Optionally, trigger a Cloud Function for notifications, etc.
    } catch (error) {
      print('Error updating order status: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to hand over order.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders for Your Products'),
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('orders')
                .where('sellerId', isEqualTo: sellerId)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No orders for your products yet.'),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children:
                snapshot.data!.docs.map((orderDoc) {
                  final orderData = orderDoc.data() as Map<String, dynamic>;
                  final List<dynamic> orderItems =
                      orderData['orderItems'] ?? [];
                  final String buyerId =
                      orderData['buyerId'] ?? 'Unknown Buyer ID';
                  final String buyerName =
                      orderData['buyerName'] ?? 'Unknown Buyer';
                  final String deliveryAddress =
                      orderData['deliveryAddress'] ?? 'Not Provided';
                  final DateTime? orderDate =
                      (orderData['orderDate'] as Timestamp?)?.toDate();
                  final String orderStatus =
                      orderData['orderStatus'] ?? 'Pending';

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order ID: ${orderDoc.id}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text('Buyer: $buyerName (ID: $buyerId)'),
                          Text('Delivery Address: $deliveryAddress'),
                          Text(
                            'Order Date: ${orderDate != null ? orderDate.toLocal().toString().split('.').first : 'N/A'}',
                          ),
                          Text('Status: $orderStatus'),
                          const SizedBox(height: 8),
                          const Text(
                            'Ordered Items:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: orderItems.length,
                            itemBuilder: (itemContext, index) {
                              final item =
                                  orderItems[index] as Map<String, dynamic>;
                              return Text(
                                '- ${item['name']} x ${item['quantity']}',
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          if (orderStatus == 'Pending')
                            ElevatedButton(
                              onPressed:
                                  () => _markAsShipped(context, orderDoc.id),
                              child: const Text('Mark as Shipped'),
                            ),
                          if (orderStatus == 'Shipped')
                            ElevatedButton(
                              onPressed:
                                  () =>
                                      _handOverToDelivery(context, orderDoc.id),
                              child: const Text('Hand to Delivery'),
                            ),
                          // You can add more actions or details here
                        ],
                      ),
                    ),
                  );
                }).toList(),
          );
        },
      ),
    );
  }
}
