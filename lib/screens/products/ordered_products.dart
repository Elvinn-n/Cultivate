import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderedProductScreen extends StatefulWidget {
  const OrderedProductScreen({Key? key}) : super(key: key);

  @override
  _OrderedProductScreenState createState() => _OrderedProductScreenState();
}

class _OrderedProductScreenState extends State<OrderedProductScreen> {
  late String buyerId;
  bool _isLoading = true;
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  // Fetch buyer's orders from Firestore
  Future<void> _fetchOrders() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      buyerId = user.uid;

      QuerySnapshot ordersSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('buyerId', isEqualTo: buyerId)
          .orderBy('orderDate', descending: true) // Order by date, newest first
          .get();

      setState(() {
        _orders = ordersSnapshot.docs.map((doc) {
          final orderData = doc.data() as Map<String, dynamic>;
          final List<dynamic> orderItems = orderData['orderItems'] ?? [];
          return {
            'orderId': doc.id, // Include the order ID
            'orderItems': orderItems.map((item) => item as Map<String, dynamic>).toList(),
            'totalAmount': orderData['totalAmount'],
            'orderDate': (orderData['orderDate'] as Timestamp?)?.toDate(),
            'status': orderData['orderStatus'],
            'paymentMethod': orderData['paymentMethod'],
            'deliveryAddress': orderData['deliveryAddress'],
            'phoneNumber': orderData['phoneNumber'],
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching orders: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching orders')),
      );
    }
  }

  Future<void> _markAsReceived(BuildContext context, String orderId) async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
          'orderStatus': 'Delivered',
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order status updated to Product Received.')),
        );
        // After successful update, you might want to refresh the order list
        _fetchOrders(); // Re-fetch orders to update the UI
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to confirm receipt.')),
        );
      }
    } catch (error) {
      print('Error updating order status: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update order status.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(child: Text('No orders placed yet'))
              : ListView.builder(
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    final List<Map<String, dynamic>> orderItems = order['orderItems'];
                    final DateTime? orderDate = order['orderDate'];
                    final String orderStatus = order['status'] ?? 'Pending';
                    final String orderId = order['orderId'] ?? ''; // Get the order ID

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order ID: $orderId',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text('Order Date: ${orderDate != null ? orderDate.toLocal().toString().split('.').first : 'N/A'}'),
                            Text('Total Amount: \$${order['totalAmount']?.toStringAsFixed(2) ?? 'N/A'}'),
                            Text('Status: $orderStatus'),
                            const SizedBox(height: 8),
                            const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: orderItems.length,
                              itemBuilder: (itemContext, itemIndex) {
                                final item = orderItems[itemIndex];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                                  child: Text('- ${item['name']} x ${item['quantity']} - \$${(item['price'] * item['quantity']).toStringAsFixed(2)}'),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Text('Payment Method: ${order['paymentMethod'] ?? 'N/A'}'),
                            Text('Delivery Address: ${order['deliveryAddress'] ?? 'N/A'}'),
                            Text('Phone Number: ${order['phoneNumber'] ?? 'N/A'}'),
                            const SizedBox(height: 16),
                            if (orderStatus == 'In Transit')
                              ElevatedButton(
                                onPressed: () => _markAsReceived(context, orderId),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Product Received'),
                              ),
                            if (orderStatus != 'In Transit' && orderStatus != 'Delivered')
                              Text('You can confirm receipt once the seller marks the order as In Transit.'),
                            if (orderStatus == 'Delivered')
                              const Text('This order has been marked as received.'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}